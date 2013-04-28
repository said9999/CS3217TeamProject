//
//  FrameConstructor.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "FrameConstructor.h"
#import "Constants.h"

//OVERVIEW: this class constructs animation frames of all game object

@implementation FrameConstructor

+ (UIImageView *)runnerWalkFrames{
    //EFFECTS: return runner's walk animation
    UIImage *frame1 = [UIImage imageNamed:@"frame-1.png"];
    UIImage *frame2 = [UIImage imageNamed:@"frame-2.png"];
    UIImage *frame3 = [UIImage imageNamed:@"frame-3.png"];
    UIImage *frame4 = [UIImage imageNamed:@"frame-4.png"];
    UIImage *frame5 = [UIImage imageNamed:@"frame-5.png"];
    UIImage *frame6 = [UIImage imageNamed:@"frame-6.png"];
    UIImage *frame7 = [UIImage imageNamed:@"frame-7.png"];
    UIImage *frame8 = [UIImage imageNamed:@"frame-8.png"];
    NSMutableArray *result = [NSMutableArray array];
    
    [result addObject:frame1];
    [result addObject:frame2];
    [result addObject:frame3];
    [result addObject:frame4];
    [result addObject:frame5];
    [result addObject:frame6];
    [result addObject:frame7];
    [result addObject:frame8];
    
    UIImageView *animation = [[UIImageView alloc] init];
    animation.animationImages = result;
    animation.animationDuration = RUNNER_WALK_DURATION;
    animation.animationRepeatCount = 0;
    
    return animation;
}

+ (UIImageView *)horseFrames {
    //EFFECTS: return horse's animation
    NSMutableArray *frames = [NSMutableArray array];
    [frames addObject:[UIImage imageNamed:@"horse-1.png"]];
    [frames addObject:[UIImage imageNamed:@"horse-2.png"]];
    [frames addObject:[UIImage imageNamed:@"horse-1.png"]];
    [frames addObject:[UIImage imageNamed:@"horse-3.png"]];
    
    UIImageView *view = [[UIImageView alloc] init];
    view.animationImages = frames;
    view.animationDuration = 0.3;
    return view;
}

@end
