//
//  AppDelegate.h
//  dsrunner
//
//  Created by sai on 3/27/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property GameCenterHelper* gcHelper;

@end
