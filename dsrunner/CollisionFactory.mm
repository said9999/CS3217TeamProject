//
//  CollisionFactory.m
//  dsrunner
//
//  Created by Light on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CollisionFactory.h"
#import "EngineConstants.h"
#import "PairHandlerManager.h"
#import <utility>
#import <map>

using namespace std;

// OVERVIEW: this class implements a factory which can be used to find the correct collision detector class for two
//           bodeis and create a CollisionInfo for them

@interface CollisionFactory () {
    PairHandlerManager *manager;
}
@end

@implementation CollisionFactory

static CollisionFactory *instance;

+ (CollisionFactory *)instance {
    if (instance == nil) {
        instance = [[CollisionFactory alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        manager = [[PairHandlerManager alloc] initWithKeyCreator:^(id obj) {
            return [obj class];
        } handlerCreator:^(id class1, id class2) {
            NSString *name = [NSString stringWithFormat:COLLISION_NAME_FORMAT, class1, class2];
            return NSClassFromString(name);
        } handlerApplication:^(id h, id obj1, id obj2) {
            return [[CollisionInfo alloc] initWithBody1:obj1 body2:obj2 detector:h];
        }];
    }
    return self;
}

- (CollisionInfo *)collisionInfoFor:(Body *)body1 :(Body *)body2 {
    // EFFECTS: return a CollisionInfo initialized with the specified bodies and the corresponding collision detector
    
    return [manager handle:body1 with:body2];
}

@end
