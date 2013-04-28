//
//  GameModel.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "GameModel.h"

// OVERVIEW: this class implements a generic model for game objects
@implementation GameModel

- (id)initWithType:(GameModelType)type center:(CGPoint)center size:(CGSize)size {
    // REQUIRES: type should be valid
    // EFFECTS: return a GameModel with given details
    
    self = [super init];
    if(self){
        self.size = size;
        self.center = center;
        self.modelType = type;
    }
    return self;
}

@end
