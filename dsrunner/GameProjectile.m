//
//  GameProjectile.m
//  dsrunner
//
//  Created by Light on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameProjectile.h"
#import "EngineConstants.h"

@interface GameProjectile () {
    CGPoint prevCenter;
}

@end

@implementation GameProjectile

- (id)initWithModel:(GameModel *)m {
    self = [super initWithModel:m];
    if (self) {
        self.velocity = [Vector2D vectorWithX:0 y:0];
        prevCenter = self.model.center;
    }
    return self;
}

- (void)update:(NSMutableArray *)newObjects {
    // reverse velocity if projectile stops moving
    if (ABS(prevCenter.x - self.body.center.x) < EPS &&
        ABS(prevCenter.y - self.body.center.y) < EPS) {
        self.velocity.x = -self.velocity.x;
        self.velocity.y = - self.velocity.y;
    }
    prevCenter = CGPointMake(self.body.center.x, self.body.center.y);
    self.body.velocity.x = self.velocity.x;
    self.body.velocity.y = self.velocity.y;
}

@end
