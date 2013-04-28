//
//  RectangleRectangleCollision.m
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EngineConstants.h"
#import "RectangleRectangleCollision.h"

double getOverlapBetweenLines(double s1, double len1, double s2, double len2) {
    // EFFECTS: return overlaps between two lines
    
    if (s1 > s2)
        return getOverlapBetweenLines(s2, len2, s1, len1);
    return MIN(s1 + len1, s2 + len2) - s2;
}

CGRect getBoundingRect(Body *body, double dt) {
    // EFFECTS: return bounding rectangle of body after time dt
    
    CGRect rect = body.boundingRect;
    rect.origin = CGPointMake(rect.origin.x + dt * body.velocity.x, rect.origin.y + dt * body.velocity.y);
    return rect;
}

// OVERVIEW: this class implements a collision detector for two rectangles
@implementation RectangleRectangleCollision

+ (void)update:(CollisionInfo *)info in:(double)dt {
    [info reset];
    
    Body *body1 = info.body1;
    Body *body2 = info.body2;
    
    CGRect rect1 = getBoundingRect(body1, dt);
    CGRect rect2 = getBoundingRect(body2, dt);
    
    double overlapX = getOverlapBetweenLines(rect1.origin.x, rect1.size.width,
                                             rect2.origin.x, rect2.size.width);
    if (overlapX <= EPS)
        return;
    
    double overlapY = getOverlapBetweenLines(rect1.origin.y, rect1.size.height,
                                             rect2.origin.y, rect2.size.height);
    if (overlapY <= EPS)
        return;
    
    double p1, p2;
    if (overlapX > overlapY) { // collision in y direction
        info.overlap = overlapY;
        info.overlapDirection = kDirectionY;
        p1 = body1.center.y;
        p2 = body2.center.y;
    } else { // collision in x direction
        info.overlap = overlapX;
        info.overlapDirection = kDirectionX;
        p1 = body1.center.x;
        p2 = body2.center.x;
    }
    if (p1 > p2) {
        info.top = body1;
        info.bottom = body2;
    } else {
        info.top = body2;
        info.bottom = body1;
    }
}

@end
