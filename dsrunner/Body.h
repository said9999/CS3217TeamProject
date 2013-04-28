//
//  Body.h
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Vector2D.h"

@interface Body : NSObject <NSCopying>
// OVERVIEW: this class is the base class for physical bodies

@property unsigned id;
@property BOOL isGravityAware;
@property BOOL isOnGround;

@property BOOL isInBackground;
@property BOOL canMoveUp;
@property BOOL canMoveAlongLine;

@property (readonly) Vector2D *velocity;

@property (readonly) Vector2D *center;
@property (readonly) CGRect boundingRect;

- (void)move:(Vector2D *)offset;
// EFFECTS: update self's center to be center + offset

@end
