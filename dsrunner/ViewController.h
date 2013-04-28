//
//  ViewController.h
//  dsrunner
//
//  Created by sai on 3/27/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObject.h"
#import "GameRunner.h"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import "GameCenterHelper.h"

// OVERVIEW: this class is the view controller of the main page scene. 

@interface ViewController : UIViewController<GCHelperDelegate,UIAlertViewDelegate>

- (IBAction)multiplayerButtonPressed:(id)sender;


@end
