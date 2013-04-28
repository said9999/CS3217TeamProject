//
//  GameModel.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameModel : NSObject
// OVERVIEW: this class implements a generic model for game objects

@property CGPoint center;
@property CGSize size;
@property GameModelType modelType;

- (id)initWithType:(GameModelType)type center:(CGPoint)center size:(CGSize)size;
    // REQUIRES: type should be valid
    // EFFECTS: return a GameModel with given details
@end
