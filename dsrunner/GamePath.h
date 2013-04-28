//
//  GameLine.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-31.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "GameObject.h"

@interface GamePath : GameObject
// OVERVIEW: this class implements a path

@property int life;
@property (readonly) NSMutableArray *lines;

- (void)addLineTo:(CGPoint)p;
- (void)refreshView;
- (void)fadeOutView;

@end
