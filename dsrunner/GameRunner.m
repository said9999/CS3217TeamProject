//
//  GameRunner.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "GameRunner.h"
#import "EngineConstants.h"

@interface GameRunner ()

@property UIImageView *walkFrames;
@property UIImageView *notOnGroundView;

@property CGPoint viewOffset;

@end

@implementation GameRunner

- (id) initWithModel:(GameModel *)model {
    self = [super initWithModel:model];
    if (self) {
        UIImage* img = [UIImage imageNamed:RUNNER_IMAGE_VIEW];
        UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
        self.notOnGroundView = imgView;
        self.walkFrames = [FrameConstructor runnerWalkFrames];
        self.walkFrames.frame = self.notOnGroundView.frame;
        self.view = self.walkFrames;
        
        self.isDead = NO;
        self.viewOffset = RUNNER_VIEW_OFFSET;
    }
    return self;
}

- (void)update:(NSMutableArray *)newObjects {
    [self moveForwardAndTurnAroundIfStopped:&_speed];
    [super update:newObjects];
    
    if (self.body.velocity.x < 0) {
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        self.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    if (self.body.center.y < OBJECT_MIN_Y)
        self.isDead = YES;
}

@end
