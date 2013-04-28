//
//  CollisionInfo.m
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CollisionInfo.h"
#import "Collision.h"

@interface CollisionInfo ()
@property Class detector;
@property Body *body1;
@property Body *body2;
@end

@implementation CollisionInfo
// OVERVIEW: this class is used to store information of collision between two bodies

- (id)initWithBody1:(Body *)body1 body2:(Body *)body2 detector:(Class)detector {
    // EFFECTS: return a CollisionInfo with properties initialized with the specified values
    
    self = [super init];
    if (self) {
        self.body1 = body1;
        self.body2 = body2;
        self.detector = detector;
        self.shouldCollide = YES;
        self.overlapDirection = kDirectionNone;
    }
    return self;
}

- (void)update:(double)dt {
    // EFFECTS: use detector to check if the two bodies collide and update relevant properties
    
    [self.detector update:self in:dt];
}

- (BOOL)doCollide {
    return self.overlapDirection != kDirectionNone;
}

- (void)reset {
    // EFFECTS: reset properties concerning a particular collision detection
    
    self.top = self.bottom = 0;
    self.overlap = 0;
    self.overlapDirection = kDirectionNone;
}

@end
