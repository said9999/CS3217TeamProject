//
//  LevelModel.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-6.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameLevel : NSObject

- (GameLevel *)initWithLevel:(NSString *) levelName;
//USAGE: init a GameLevel with given levelName. e.g. "level1.xml"

@property (readonly) NSArray *models;
//USAGE: return the list of models specified in the level file
//       all models are in the same list, therefore ViewController should
//       differentiate the type of each model

@property (readonly) int width;
//EFFECTS: return the width of the level

@property (readonly) int speed;
//EFFECTS: return the speed of the level

@property (readonly) int ink;
//EFFECTS: return the amount of ink of the level

@property (readonly) CGPoint startPoint;
@end
