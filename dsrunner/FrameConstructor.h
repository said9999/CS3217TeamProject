//
//  FrameConstructor.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameConstructor : NSObject
//OVERVIEW: this class constructs animation frames of all game object

+ (UIImageView*)runnerWalkFrames;
//EFFECTS: return the runner walk frames

+ (UIImageView*)horseFrames;
//EFFECTS: return horse's animations

@end
