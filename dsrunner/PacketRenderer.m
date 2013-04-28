//
//  PacketRenderer.m
//  dsrunner
//
//  Created by sai on 4/17/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//


#import "PacketRenderer.h"
#import "GameModel.h"
#import "Constants.h"
#import "PathView.h"

#define SMALL_VIEW_HEIGHT 208
#define DEVIATION_IN_SMALL_VIEW 2.5
#define MANUAL_RATIO 0.35
#define SMALL_LINE_THICKNESS 2
#define ENEMYSMALL_IMG @"horse-1.png"
#define GIFTSMALL_IMG @"questionMark-small.png"

@interface PacketRenderer(){
    UIImage *smallGround,
            *smallEnemy,
            *smallRunner,
            *smallProjectile,
            *smallQuestionMark;
    CGFloat width;
    int oldOffSet;
    NSMutableArray *multiviews;
    UIView *multiplayerView;
    GameLevel *level;
    NSMutableData *receiveData;
}
@end

static PacketRenderer *instance;

@implementation PacketRenderer

+ (id) sharedInstance{
    if (instance == nil) {
        instance = [[PacketRenderer alloc] init];
    }
    return instance;
}

- (id)init{
    self = [super init];
    [self prepareSmallImgsForMultiPlayerWindow];
    return self;
}

/**EFFECT:
 * This class is singleton pattern, so some data needs to be refreshed regularly
 */
- (void)refreshData{
    oldOffSet = 0;
    multiviews = [NSMutableArray array];
    multiplayerView = [self.delegate getCanvas];
    level = [self.delegate getLevel];
    width = level.width;
}

/**EFFECT:
 * This method will render the map(only backgrounds) of multiplayer view before the game.
 */
- (void)renderMap{
    for (GameModel *model in level.models) {
        if (model.modelType == GameModelGround ||
            model.modelType == GameModelGift)
        {
            UnitData blockData = {model.modelType,
                                    model.size,
                                    model.center};
            [self addToMultiViewWithModel :blockData];
        }
    }
}

- (void)receivePacket: (NSData*)data{
    [self removeMultiViews];
    receiveData = (NSMutableData*)data;
    int type;
    [receiveData getBytes:&type length:sizeof(type)];
    
    switch (type) {
        case GAMEDATA_FOREGROUND:
            [self renderForeground];
            break;
        case GAMEDATA_WIN:
            [self.delegate failGame];
            break;
        case GAMEDATA_DIE:
            [self.delegate clearGame];
            break;
        case GAMEDATA_GIFT:
            [self enableGift];
            break;
        default:
            break;
    }
}

/**EFFECT:
 * This method render the foreground and paths of the opponet player into multiplayer view
 */
- (void)renderForeground{
    int numGameObjects;
    int boardOffset;
    int offset = sizeof(int);
    
    [receiveData getBytes:&boardOffset
                    range:NSMakeRange(offset, sizeof(int))];
    offset += sizeof(int);
    
    [receiveData getBytes:&numGameObjects
                    range:NSMakeRange(offset, sizeof(int))];
    offset += sizeof(int);
    
    if (boardOffset != oldOffSet) {//offset has changed so need to forward screen
        [self forwardMultiPlayerScreen];
        oldOffSet = boardOffset;
    }
    
    [self addGameObjectsToMultiPlayerWindowWithOffset:offset
                                             AndNumGameObjects:numGameObjects];
    offset += numGameObjects * sizeof(UnitData);
    
    [self addPathsToMultiPlayerWindowWithOffset:offset];
}

/**EFFECT:
 * This method is called when the opponet send a gift packet to this player,
 * Hence, some special effects will happen to this player according to the gift type
 */
- (void)enableGift{
    int giftType;
    [receiveData getBytes:&giftType
             range:NSMakeRange(sizeof(int), sizeof(int))];
    
    switch (giftType) {
        case GIFTTYPE_ADDENEMY:
            [self.delegate addEnemyInScreen];
            break;
        case GIFTTYPE_BLINK:
            [self.delegate blinkOneSecond];
            break;
        case GIFTTYPE_NOMANA:
            [self.delegate noMana];
            break;
        case GIFTTYPE_STUCK:
            [self.delegate stuckRunner];
            break;
        case GIFTTYPE_UPSIDEDOWN:
            [self.delegate upsideDown];
            break;
        default:
            break;
    }
}

- (void)forwardMultiPlayerScreen{
    double deviation = MIN(BOARD_UNIT_OFFSET, width-oldOffSet-SCREEN_WIDTH) * 1.0;
    deviation = deviation * MULTIVIEW_RATIO;
    
    if (deviation > 0) {
        multiplayerView.center = CGPointMake(multiplayerView.center.x - deviation,
                                             multiplayerView.center.y);
    }
    
}

- (void)addToMultiViewWithModel:(UnitData)blockData{
    UIView *view = [[UIView alloc] init];
    
    switch (blockData.type) {
        case GameModelGround:
            view.backgroundColor = [UIColor colorWithPatternImage:smallGround];
            break;
        case GameModelEnemy:
            view.backgroundColor = [UIColor colorWithPatternImage:smallEnemy];
            [self shouldTransitionView:view :(blockData.orientation<0)];
            break;
        case GameModelRunner:
            view.backgroundColor = [UIColor colorWithPatternImage:smallRunner];
            [self shouldTransitionView:view :(blockData.orientation>0)];
            break;
        case GameModelGift:
            view.backgroundColor = [UIColor colorWithPatternImage:smallQuestionMark];
            break;
        
        default:
            break;
    }
    
    [self paintCanvasWithView:view AndData:blockData];
}

- (void)addPathsToMultiPlayerWindowWithOffset:(int)offset{
    int numPaths;
    [receiveData getBytes:&numPaths range:NSMakeRange(offset, sizeof(int))];
    offset += sizeof(int);
    
    for (int i = 0; i < numPaths; i++) {
        int inkType;
        [receiveData getBytes:&inkType range:NSMakeRange(offset, sizeof(int))];
        offset += sizeof(int);
        
        int numPoints;
        [receiveData getBytes:&numPoints range:NSMakeRange(offset, sizeof(int))];
        offset += sizeof(int);
        
        PathView *view = [[PathView alloc] initWithFrame:CGRectMake(0, 0, level.width * MULTIVIEW_RATIO, SMALL_VIEW_HEIGHT)];
        view.inkType = inkType;
        view.thickness = SMALL_LINE_THICKNESS;
        
        for (int j = 0; j < numPoints; j++) {
            CGPoint point;
            [receiveData getBytes:&point range:NSMakeRange(offset, sizeof(CGPoint))];
            offset += sizeof(CGPoint);
            point = CGPointMake(point.x, point.y);
            [view addPoint:[self pointForPath:point]];
        }
        [view setNeedsDisplay];
        [multiplayerView addSubview:view];
        [multiviews addObject:view];
    }
}

- (void)shouldTransitionView:(UIView*)view :(BOOL)shouldTransition{
    if (shouldTransition) {
        view.transform = CGAffineTransformScale(view.transform, -1, 1);
    }else{
        view.transform = CGAffineTransformScale(view.transform, 1, 1);
    }
}

- (void)paintCanvasWithView:(UIView *)view AndData:(UnitData)blockData{
    view.frame = [self toMultiViewFrame:CGRectMake(0, 0, blockData.size.width, blockData.size.height)];
    view.center =  [self toMultiViewCenter:blockData.center];
    [multiplayerView addSubview:view];
    
    if (blockData.type != GameModelGround &&
        blockData.type != GameModelGift) {
        [multiviews addObject:view];
    }
}

- (void)addGameObjectsToMultiPlayerWindowWithOffset:(int)offset AndNumGameObjects:(int)count{
    for (int i=0; i<count; i++) {
        UnitData unitData;
        [receiveData getBytes:&unitData range:NSMakeRange(offset+i*sizeof(UnitData), sizeof(UnitData))];
        [self addToMultiViewWithModel:unitData];
    }
}


- (void) prepareSmallImgsForMultiPlayerWindow{
    smallGround = [self createSmallImgWithName:BRICK_GROUND_IMAGE];
    smallRunner = [self createSmallImgWithName:RUNNER_IMAGE_VIEW];
    smallEnemy = [self createSmallImgWithName:ENEMYSMALL_IMG AndManulRatio:MANUAL_RATIO];
    smallQuestionMark = [UIImage imageNamed:GIFTSMALL_IMG];
}

- (UIImage *)createSmallImgWithName:(NSString *)name{
    UIImage *img = [UIImage imageNamed:name];
    CGSize imgSize = CGSizeMake(img.size.width * MULTIVIEW_RATIO,
                                img.size.height * MULTIVIEW_RATIO);
    return [self imageWithImage:img scaledToSize:imgSize];
}

- (UIImage *)createSmallImgWithName:(NSString *)name AndManulRatio:(double)ratio{
    UIImage *img = [UIImage imageNamed:name];
    CGSize imgSize = CGSizeMake(img.size.width * MULTIVIEW_RATIO * ratio,
                                img.size.height * MULTIVIEW_RATIO * ratio) ;
    return [self imageWithImage:img scaledToSize:imgSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)removeMultiViews{
    for (UIView* view in multiviews ) {
        [view removeFromSuperview];
    }
    multiviews = [NSMutableArray array];
}

- (CGRect)toMultiViewFrame:(CGRect)frame{
    return CGRectMake(0, 0, frame.size.width * MULTIVIEW_RATIO,frame.size.height * MULTIVIEW_RATIO);
}

- (CGPoint)toMultiViewCenter: (CGPoint)center{
    return CGPointMake(center.x * MULTIVIEW_RATIO, SMALL_VIEW_HEIGHT - center.y * MULTIVIEW_RATIO+DEVIATION_IN_SMALL_VIEW);
}

- (CGPoint)pointForPath:(CGPoint)pt{
    return CGPointMake(pt.x * MULTIVIEW_RATIO, pt.y * MULTIVIEW_RATIO);
}
@end
