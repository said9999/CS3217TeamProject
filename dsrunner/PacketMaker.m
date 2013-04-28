//
//  PacketMaker.m
//  dsrunner
//
//  Created by sai on 4/16/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
#import "PacketMaker.h"
#import "GameObject.h"
#import "RectGameObject.h"
#import "Constants.h"
#import "GamePath.h"
#import "PathView.h"

#define NUM_TRIGGERS 5

static PacketMaker *instance;

@implementation PacketMaker


+ (id) sharedInstance{
    if (instance == nil) {
        instance = [[PacketMaker alloc] init];
    }
    return instance;
}

- (id)init{
    self = [super init];
    return self;
}


- (NSData*)sendPacketWithType:(GAMEDATA) dataType{
    NSMutableData *packet = [NSMutableData data];
    
    switch (dataType) {
        case GAMEDATA_FOREGROUND:
            packet = [self foregroundDataPacket];
            break;
        case GAMEDATA_WIN:
            packet = [self winPacket];
            break;
        case GAMEDATA_DIE:
            packet = [self diePacket];
            break;
        case GAMEDATA_GIFT:
            packet = [self giftPacketAndUpdataMultiPlayerWindow];
            break;
        default:
            break;
    }
    
    return packet;
}

/**EFFECT:
 * This method wrap all foreground game objects in current screen to a packet.
 * The data is stored as
 *  PACKET_TYPE -> NUM_OBJECTS -> OBJECTS ->.... ->OBJECTS -> PATHPACKET
 */
- (NSMutableData*)foregroundDataPacket{
    NSMutableData *packet = [NSMutableData data];
    int boardOffset = [self.delegate getCurrentOffset];
    int packetType = GAMEDATA_FOREGROUND;
    [packet appendBytes:&packetType length:sizeof(int)];
    [packet appendBytes:&boardOffset length:sizeof(int)];
    
    int numValidGameObjects=0;
    NSMutableData *appendData = [NSMutableData data];
    for (RectGameObject *obj in [self.delegate getForegroundObjects]) {
        if ([self objectInValidPosition:obj WithOffset:boardOffset]){
            UnitData data = [self wrapUnitData:obj];
            [appendData appendBytes:&data length:sizeof(UnitData)];
            numValidGameObjects++;
        }
    }
    
    [packet appendBytes:&numValidGameObjects length:sizeof(int)];
    [packet appendData:appendData];
    [packet appendData:[self pathsPacket]];
    return packet;
}

- (NSMutableData*)winPacket{
    int type = GAMEDATA_WIN;
    NSMutableData *packet = [NSMutableData dataWithBytes:&type
                                                  length:sizeof(int)];
    return packet;
}

- (NSMutableData*)diePacket{
    int type = GAMEDATA_DIE;
    NSMutableData *packet = [NSMutableData dataWithBytes:&type
                                                  length:sizeof(int)];
    return packet;
}

/** EFFECT:
 *  This packet is appended to the foreground packet 
 *  Its data is stored as
 *  NUM_PATHS -> (INKTYPE->PATH) -> ... -> (INKTYPE-> PATH)
 */
- (NSMutableData*)pathsPacket{
    NSArray *paths = [self.delegate getPaths];
    NSMutableData *packet = [NSMutableData data];
    int numPathsInView = [paths count];
    
    [packet appendBytes:&numPathsInView
                   length:sizeof(int)];
    for (GamePath *obj in paths) {
        PathView *view = (PathView *)obj.view;
        int type = obj.model.modelType;
        int pointsCount = [view.points count];
        
        [packet appendBytes:&type length:sizeof(int)];
        [packet appendBytes:&pointsCount length:sizeof(int)];
        for (NSValue *value in view.points) {
            CGPoint point = [value CGPointValue];
            [packet appendBytes:&point length:sizeof(CGPoint)];
        }
    }
    return packet;
}

/**EFFECT:
 * This method return a giftpacket and change the multiplayer view of current player
 * to see what happens to the opponet
 */
- (NSMutableData*)giftPacketAndUpdataMultiPlayerWindow{
    int giftType = arc4random_uniform(NUM_TRIGGERS);
    [self updateMultiPlayerWindowWithType:giftType];
    GiftData data = {GAMEDATA_GIFT , giftType};
    NSMutableData *packet = [NSMutableData dataWithBytes:&data
                                                  length:sizeof(GiftData)];
    return packet;
}

- (void)updateMultiPlayerWindowWithType:(int)giftType{
    if (giftType == GIFTTYPE_BLINK) {
        [self.delegate blinkMultiScreen];
    } else if (giftType == GIFTTYPE_UPSIDEDOWN){
        [self.delegate upsideDownMultiScreen];
    }
}

- (BOOL)objectInValidPosition:(RectGameObject *)obj WithOffset:(int)boardOffset{
    if(obj.body.center.x >= boardOffset
       && obj.body.center.x <= boardOffset + SCREEN_WIDTH)
        return true;
    return false;
}

- (UnitData)wrapUnitData:(RectGameObject *)obj{
    UnitData data = {obj.model.modelType,
                    CGSizeMake(obj.view.frame.size.width,obj.view.frame.size.height),
                    CGPointMake(obj.body.center.x, obj.body.center.y),
                    (int)obj.body.velocity.x};
    return data;
}


@end
