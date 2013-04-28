//
//  CollisionInfo.h
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Body.h"

typedef enum {
    kDirectionNone = 0, // no overlap
    kDirectionX = 1,
    kDirectionY = 2,
} Direction;

@interface CollisionInfo : NSObject
// OVERVIEW: this class is used to store information of collision between two bodies

@property (readonly) Class detector;
@property (readonly) Body *body1;
@property (readonly) Body *body2;

@property BOOL shouldCollide;
@property Body *top;
@property Body *bottom;
@property double overlap;
@property Direction overlapDirection;
@property (readonly) BOOL doCollide;

- (id)initWithBody1:(Body *)body1 body2:(Body *)body2 detector:(Class)detector;
// EFFECTS: return a CollisionInfo with properties initialized with the specified values

- (void)update:(double)dt;
// EFFECTS: use detector to check if the two bodies collide and update relevant properties

- (void)reset;
// EFFECTS: reset properties concerning a particular collision detection
//          (top, bottom, overlap, overlapDirection)

@end
