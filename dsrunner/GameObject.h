//
//  GameObject.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GameModel.h"
#import "Body.h"

@interface GameObject : UIViewController
// OVERVIEW: this class is the base class for objects in the game

@property (nonatomic, readonly) GameModel *model;
@property (readonly) CGPoint viewOffset;

- (id)initWithModel:(GameModel *)m;
// EFFECTS: return a GameObject with model = m

- (void)update:(NSMutableArray *)newObjects;
// EFFECTS: update self at a game step.
//          If new game objects(e.g. projectiles) are created, they should be added to newObjects.

- (void)startAnimation;
// EFFECTS: start current animation

- (void)stopAnimation;
// EFFECTS: stop current animation

@end
