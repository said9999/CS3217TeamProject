//
//  Vector2D.h
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

@interface Vector2D : NSObject
// OVERVIEW: this class implements a 2 dimentional vector

@property double x;
@property double y;

+ (Vector2D *)vectorWithX:(double)x y:(double)y;
// EFFECTS: return a 2d vector with the specified x and y

- (Vector2D *)add:(Vector2D *)v;
// EFFECTS: return a new 2d vector equal to self + v

- (Vector2D *)mul:(double)scale;
// EFFECTS: return a vector 2d vector equal to self * scale

- (double)dot:(Vector2D *)v;
// EFFECTS: return dot product of self  and v

@end
