//
//  PacketRenderer.h
//  dsrunner
//
//  Created by sai on 4/17/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "GameLevel.h"

@protocol RenderDelegate <NSObject>

- (void)failGame;
- (void)clearGame;
- (void)addEnemyInScreen;
- (void)noMana;
- (void)stuckRunner;
- (void)blinkOneSecond;
- (void)upsideDown;
- (GameLevel*)getLevel;
- (UIView*)getCanvas;

@end

/**OVERVIEW:
 * This class is rendering all coming packts from the opponent
 * The pattern is singleton here
 * Its delegate is SingleViewController
 */
@interface PacketRenderer : NSObject

@property id<RenderDelegate> delegate;

+ (id) sharedInstance;
//EFFECT: return a shared instance
- (void)receivePacket:(NSData*)data;
//EFFECT: receive a packet and render it
- (void)renderMap;
//EFFECT: render background map before playing the game
- (void)refreshData;
//EFFECT: get data from the delegate
@end
