//
//  GameRunner.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "RectGameObject.h"
#import "FrameConstructor.h"

@interface GameRunner : RectGameObject
// OVERVIEW: this class implements a runner

@property UIImageView *view;
@property (nonatomic) BOOL isDead;
@property int speed;

@end
