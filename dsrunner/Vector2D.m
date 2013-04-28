//
//  Vector2D.m
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Vector2D.h"

// OVERVIEW: this class implements a 2 dimentional vector
@implementation Vector2D

+ (Vector2D *)vectorWithX:(double)x y:(double)y {
    // EFFECTS: return a 2d vector with the specified x and y
    
    Vector2D *v = [[Vector2D alloc] init];
    v.x = x;
    v.y = y;
    return v;
}

- (Vector2D *)add:(Vector2D *)v {
    // EFFECTS: return a new 2d vector equal to self + v
    
    return [Vector2D vectorWithX:self.x + v.x y:self.y + v.y];
}

- (Vector2D *)mul:(double)scale {
    // EFFECTS: return a vector 2d vector equal to self * scale
    
    return [Vector2D vectorWithX:self.x * scale y:self.y *scale];
}

- (double)dot:(Vector2D *)v {
    // EFFECTS: return dot product of self  and v
    
    return self.x * v.x + self.y * v.y;
}

@end
