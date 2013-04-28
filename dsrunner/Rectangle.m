//
//  Rect.m
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EngineConstants.h"
#import "Rectangle.h"

@implementation Rectangle
// OVERVIEW: this class implements a rectangle in physical world

- (id)initWithWidth:(double)w height:(double)h {
    // EFFECTS: return a Rectangle with width = w and height = h
    
    self = [super init];
    if (self ) {
        self.width = w;
        self.height = h;
    }
    return self;
}

+ (Rectangle *)rectWithWidth:(double)w height:(double)h {
    // EFFECTS: return a Rectangle with width = w and height = h
    
    return [[Rectangle alloc] initWithWidth: w height: h];
}

- (CGRect)boundingRect {
    return CGRectMake(self.center.x - self.width / 2, self.center.y - self.height / 2, self.width, self.height);
}

@end
