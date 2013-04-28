//
//  RectGameObject.m
//  dsrunner
//
//  Created by Light on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RectGameObject.h"
#import "EngineConstants.h"

@interface RectGameObject ()

@end

@implementation RectGameObject

- (id)initWithModel:(GameModel *)m {
    self = [super initWithModel:m];
    if (self) {
        self.body = [Rectangle rectWithWidth:m.size.width height:m.size.height];
        self.body.center.x = m.center.x;
        self.body.center.y = m.center.y;
        self.lastCenter = m.center;
    }
    return self;
}

- (void)update:(NSMutableArray *)newObjects {
    self.lastCenter = CGPointMake(self.body.center.x, self.body.center.y);
}

- (BOOL)hasCenterXChanged {
    return ABS(self.body.center.x - self.lastCenter.x) > EPS;
}

- (void)moveForwardAndTurnAroundIfStopped:(int*)v {
    if (self.body.isOnGround && !self.hasCenterXChanged) {
        *v = -*v;
    }
    self.body.velocity.x = *v;
}

@end
