//
//  GameLine.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-31.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "GamePath.h"
#import "Line.h"
#import "PathView.h"

@interface GamePath()

@property NSMutableArray *lines;

@end


@implementation GamePath

- (id)initWithModel:(GameModel *)m {
    self = [super initWithModel:m];
    if (self) {
        self.lines = [NSMutableArray array];
        PathView *view = [[PathView alloc] init];
        view.inkType = m.modelType == GameModelBlockPath ? GameModelBlockPath : GameModelReflectPath;
        self.view = view;
    }
    return self;
}

- (void)fadeOutView {
    UIImageView *view = (UIImageView*)self.view;
    view.hidden = NO;
    view.alpha = 1.0f;
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)refreshView {
    [self.view setNeedsDisplay];
}

- (void)addLineTo:(CGPoint)p {
    [(PathView *)self.view addPoint:CGPointMake(p.x, p.y)];
}

@end
