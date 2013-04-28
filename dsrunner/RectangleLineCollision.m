//
//  RectangleLineCollision.m
//  PhysicsEngine
//
//  Created by Light on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EngineConstants.h"
#import "RectangleLineCollision.h"
#import "Line.h"

@implementation RectangleLineCollision
// OVERVIEW: this class implements a collision detector for two rectangles

+ (void)update:(CollisionInfo *)info in:(double)dt {
    [info reset];
    
    Body *body1 = info.body1;
    Body *body2 = info.body2;
    
    CGRect rect = body1.boundingRect;
    rect.origin = CGPointMake(rect.origin.x + dt * body1.velocity.x, rect.origin.y + dt * body1.velocity.y);
    
    Line *l = (Line *)body2;
    Vector2D *offset = [body2.velocity mul:dt];
    Vector2D *p1 = [l.p1 add:offset];
    Vector2D *p2 = [l.p2 add:offset];
    
    double minX = p1.x;
    double maxX = p2.x;
    if (p1.x > p2.x) {
        minX = p2.x;
        maxX = p1.x;
    }
    
    minX = MAX(minX, rect.origin.x);
    maxX = MIN(maxX, rect.origin.x + rect.size.width);
    
    if (maxX - minX < 0) return;
    
    double minY = p1.y;
    double maxY = p2.y;
    
    double dx = p2.x - p1.x;
    
    double a, b;
    if (ABS(dx) > EPS) {
        a = (p2.y - p1.y) / dx;
        b = p1.y - a * p1.x;
        minY = a * minX + b;
        maxY = a * maxX + b;
    }
    
    if (minY > maxY) {
        double tmp = maxY;
        maxY = minY;
        minY = tmp;
    }
    
    maxY = MIN(maxY, rect.origin.y + rect.size.height);
    minY = MAX(minY, rect.origin.y);
    
    if (maxY - minY < 0) return;
    
    double y1 = minY;
    double y2 = maxY;
    double x1, x2;
    if (ABS(dx) > EPS) {
        if (ABS(a) > EPS) {
            x1 = (y1 - b) / a;
            x2 = (y2 - b) / a;
        } else {
            x1 = minX;
            x2 = maxX;
        }
    } else {
        x1 = x2 = p1.x;
    }
    
    if (ABS(x1 - x2) < EPS && ABS(y1 - y2) < EPS) return;
    
    maxX = MAX(x1, x2);
    minX = MIN(x1, x2);
    double overlapX = maxX - rect.origin.x;
    double overlapY = maxY - rect.origin.y;
    if (overlapX < EPS || overlapY < EPS) return;
    
    CGPoint contactPointToRectCenter = CGPointMake(x1 + x2 - rect.size.width - 2 * rect.origin.x,
                                                   y1 + y2 - rect.size.height - 2 * rect.origin.y);
    double s1, s2;
    
    // moving up along a line, should be moved to somewhere else
    if (body1.canMoveAlongLine && body1.canMoveUp && body1.velocity.x * contactPointToRectCenter.x > 0) {
        double yGap = MIN(p1.y, p2.y) - rect.origin.y;
        if (ABS(dx) > EPS && ABS(a) < LIFT_LINE_SLOPE_THRESHOLD && body1.velocity.x * a >= 0 &&
            yGap < LIFT_LINE_Y_THRESHOLD) {
            body1.center.y += MAX(0, yGap);
            body1.velocity.y = a *body1.velocity.x;
            info.overlapDirection = kDirectionY;
            info.overlap = 0;
            info.top = body1;
            info.bottom = body2;
            return;
        }
    }
    
    if (overlapY < overlapX && ABS(body1.velocity.y) > EPS && body1.velocity.y * contactPointToRectCenter.y > 0) {
        // collision in y direction
        info.overlapDirection = kDirectionY;
        info.overlap = overlapY;
        s1 = body1.center.y;
        s2 = (y1 + y2) / 2;
    } else {
        // collision in x direction
        info.overlapDirection = kDirectionX;
        info.overlap = overlapX;
        s1 = body1.center.x;
        s2 = (x1 + x2) / 2;
    }
    
    if (s1 > s2) {
        info.top = body1;
        info.bottom = body2;
    } else {
        info.top = body2;
        info.bottom = body1;
    }
}

@end
