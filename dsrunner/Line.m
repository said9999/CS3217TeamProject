//
//  Line.m
//  PhysicsEngine
//
//  Created by Light on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Line.h"

@implementation Line
// OVERVIEW: this class implements a line in physical world

- (id)initWithX1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2 {
    // EFFECTS: return a Line with p1 = (x1, y1), p2 = (x2, y2)
    
    self = [super init];
    if (self) {
        self.p1 = [Vector2D vectorWithX:x1 y:y1];
        self.p2 = [Vector2D vectorWithX:x2 y:y2];
        self.isGravityAware = NO;
    }
    return self;
}

+ (Line *)lineWithX1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2 {
    // EFFECTS: return a Line with p1 = (x1, y1), p2 = (x2, y2)
    
    return [[Line alloc] initWithX1:x1 y1:y1 x2:x2 y2:y2];
}

- (Vector2D *)center {
    return [Vector2D vectorWithX:(self.p1.x + self.p2.x) / 2 y:(self.p1.y + self.p2.y) / 2];
}

- (CGRect)boundingRect {
    return CGRectMake(MIN(self.p1.x, self.p2.x), MIN(self.p1.y, self.p2.y),
                      ABS(self.p1.x - self.p2.x), ABS(self.p1.y - self.p2.y));
}

- (void)move:(Vector2D *)offset {
    self.p1.x += offset.x;
    self.p1.y += offset.y;
    self.p2.x += offset.x;
    self.p2.y += offset.y;
}

@end
