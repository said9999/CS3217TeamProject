//
//  GameControllerDelegate.h
//  dsrunner
//
//  Created by Light on 19/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RectGameObject.h"

@protocol GameControllerDelegate <NSObject>
// OVERVIEW: this protocol is used by Game to inform game owner about some game events and updates of views

- (void)didIncreaseInkPoints;
- (void)didSendGift;

- (void)clearGame;
- (void)failGame;

- (void)addGameView:(UIView *)view;

- (void)didUseUpInk;

@end
