//
//  BufferViewController.h
//  dsrunner
//
//  Created by Cui Wei on 4/19/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterHelper.h"

// OVERVIEW: this class is the view controller of the start scene. It handles
// Game Center Log in to allow multiplayer mode via game center.

@interface BufferViewController : UIViewController<GCHelperLogInDelegate>


- (void)userDidCancelLogIn;
//EFFECT: prompt alert to inform user game center not available due to their cancellation

@end
