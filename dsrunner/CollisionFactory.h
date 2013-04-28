//
//  CollisionFactory.h
//  dsrunner
//
//  Created by Light on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Body.h"
#import "CollisionInfo.h"

@interface CollisionFactory : NSObject
// OVERVIEW: this class implements a factory which can be used to find the correct collision detector class for two
//           bodeis and create a CollisionInfo for them

+ (CollisionFactory *)instance;
// EFFECTS: return a CollisionFactory singleton instance

- (CollisionInfo *)collisionInfoFor:(Body *)body1 :(Body *)body2;
// EFFECTS: return a CollisionInfo initialized with the specified bodies and the corresponding collision detector

@end
