//
//  GameDestination.m
//  dsrunner
//
//  Created by Light on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameDestination.h"
#import <QuartzCore/QuartzCore.h>

@interface GameDestination ()

@end

@implementation GameDestination

- (void)startAnimation {
    [self spinView:self.view duration:5 repeat:MAXFLOAT];
}

- (void)stopAnimation {
    [self.view.layer removeAllAnimations];
}

- (void) spinView:(UIView*)view duration:(CGFloat)duration repeat:(float)repeat {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
