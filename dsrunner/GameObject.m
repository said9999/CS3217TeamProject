//
//  GameObject.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "GameObject.h"

// OVERVIEW: this class is the base class for objects in the game
@interface GameObject ()

@property (nonatomic) GameModel *model;
@property CGPoint viewOffset;

@end

@implementation GameObject

- (id)initWithModel:(GameModel *) m{
    // EFFECTS: return a GameObject with model = m
    
    self = [super init];
    if (self) {
        self.model = m;
        self.viewOffset = CGPointMake(0, 0);
    }
    return self;
}

- (void)update:(NSMutableArray *)newObjects {
}

- (void)startAnimation {
    // EFFECTS: start current animation
    
    if ([self.view isKindOfClass:[UIImageView class]])
        [(UIImageView *)self.view startAnimating];
}

- (void)stopAnimation {
    // EFFECTS: stop current animation
    
    if ([self.view isKindOfClass:[UIImageView class]]) {
        id view = self.view;
        [view stopAnimating];
        if ([view animationImages] != nil)
            [view setImage:[[view animationImages] objectAtIndex:0]];
    }
}

@end
