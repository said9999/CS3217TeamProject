//
//  Line.h
//  PhysicsEngine
//
//  Created by Light on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Body.h"

@interface Line : Body
// OVERVIEW: this class implements a line in physical world

@property Vector2D *p1;
@property Vector2D *p2;

- (id)initWithX1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2;
// EFFECTS: return a Line with p1 = (x1, y1), p2 = (x2, y2)

+ (Line *)lineWithX1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2;
// EFFECTS: return a Line with p1 = (x1, y1), p2 = (x2, y2)

@end
