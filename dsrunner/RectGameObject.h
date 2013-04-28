//
//  RectGameObject.h
//  dsrunner
//
//  Created by Light on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameObject.h"
#import "Rectangle.h"

@interface RectGameObject : GameObject
// OVERVIEW: this class implements a game object with rectangle body

@property Rectangle *body;
@property CGPoint lastCenter;

@property (readonly) BOOL hasCenterXChanged;

- (void)moveForwardAndTurnAroundIfStopped:(int*)v;
    
@end
