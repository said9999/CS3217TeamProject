//
//  Rect.h
//  PhysicsEngine
//
//  Created by Light on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Body.h"
#import "Vector2D.h"

@interface Rectangle : Body
// OVERVIEW: this class implements a rectangle in physical world

@property double width;
@property double height;

- (id)initWithWidth:(double)w height:(double)h;
// EFFECTS: return a Rectangle with width = w and height = h

+ (Rectangle *)rectWithWidth:(double)w height:(double)h;
// EFFECTS: return a Rectangle with width = w and height = h

@end
