//
//  Collision.h
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Body.h"
#import "CollisionInfo.h"

@interface Collision : NSObject
// OVERVIEW: this class is the base class for collision detectors

+ (void)update:(CollisionInfo *)c in:(double)dt;
// EFFECTS: detect collision between two bodies after time dt in the specified CollisionInfo,
//          and update relevant properties in the CollisionInfo

@end
