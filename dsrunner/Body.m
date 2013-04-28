//
//  Body.m
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Body.h"

// OVERVIEW: this class is the base class for physical bodies
@interface Body ()

@property Vector2D *center;
@property Vector2D *velocity;

@end

@implementation Body

- (id)init {
    // EFFECTS: return a Body with properties initialized with default values
    
    self = [super init];
    if (self) {
        self.velocity = [Vector2D vectorWithX:0 y:0];
        self.isInBackground = NO;
        self.isOnGround = NO;
        self.center = [Vector2D vectorWithX:0 y:0];
        self.isGravityAware = YES;
        self.canMoveAlongLine = YES;
    }
    return self;
}

- (CGRect)boudingRect {
    return CGRectMake(0, 0, 0, 0);
}

- (void)move:(Vector2D *)offset {
    // EFFECTS: update self's center to be center + offset
    
    self.center.x += offset.x;
    self.center.y += offset.y;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
