//
//  LevelModel.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-6.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameLevel.h"
#import "XMLParser.h"
#import "GameModel.h"

@interface GameLevel ()

@property NSDictionary *loadedFromFile;
@property int width;
@property int ink;
@property int speed;

@property NSArray *models;
@property CGPoint startPoint;
@end

@implementation GameLevel

- (GameLevel *)initWithLevel:(NSString *) levelName{
    
    self = [super init];
    if(self){
        self.loadedFromFile = [[XMLParser parseXML:levelName] objectForKey:LEVEL_NAME];
        [self setInkAndWidth];
        self.models = [NSMutableArray array];
        [self setBlockList];
        [self setEnemyList];
        [self setDestination];
        [self setInkList];
        [self setGiftList];
    }
    return self;
}

- (void)setInkAndWidth {
    self.width = [[self.loadedFromFile objectForKey:WIDTH_STRING] intValue];
    self.ink = [[self.loadedFromFile objectForKey:INK_STRING] intValue];
    self.speed = [[self.loadedFromFile objectForKey:SPEED_STRING] intValue];
    self.startPoint = CGPointMake([[self.loadedFromFile objectForKey:X_STRING] intValue],
                                  [[self.loadedFromFile objectForKey:Y_STRING] intValue]);
}
- (void)setBlockList {
    [self readList:GROUND_NAME withType:GameModelGround];
}

- (void)setEnemyList {
    [self readList:ENEMY_NAME withType:GameModelEnemy];
}

- (void)setDestination {
    [self readList:DESTINATION_NAME withType:GameModelDestination];
}

- (void)setInkList{
    [self readList:@"redink" withType:GameModelRedInk];
    //[self readList:@"greenink" withType:GameModelGreenInk];
}

- (void)setGiftList{
    [self readList:@"gift" withType:GameModelGift];
}
- (void)readList:(NSString *)name withType:(GameModelType)type {
    NSDictionary *dict = [self.loadedFromFile objectForKey:name];
    for (id obj in dict) {
        GameModel *model = [self getModel:obj type:type];
        if (model != nil)
            [(NSMutableArray *)self.models addObject:model];
    }
}

- (GameModel *)getModel:(id)obj type: (GameModelType)type {
    int width = [[obj objectForKey:WIDTH_STRING] intValue];
    if(width == -1) return nil;
    int height = [[obj objectForKey:HEIGHT_STRING] intValue];
    int x = [[obj objectForKey:X_STRING] intValue];
    int y = [[obj objectForKey:Y_STRING] intValue];
    CGPoint ctr = CGPointMake(x, y);
    GameModel *model = [[GameModel alloc] initWithType:type center:ctr size:(CGSizeMake(width, height))];
    return model;
}

@end
