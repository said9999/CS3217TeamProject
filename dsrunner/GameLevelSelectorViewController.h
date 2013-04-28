//
//  GameLevelSelectorViewController.h
//  dsrunner
//
//  This is the view controller of the game level selector interface.
//  It is called from the root view controller, and view segue to
//  single-player mode view controller, and load the level based on the
//  level selected by the player.
//
//  Created by Cui Wei on 4/7/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

//Overview: this class is the ViewController of GameSelect view
//          it contains buttons of each level.
@interface GameLevelSelectorViewController : UIViewController <UIActionSheetDelegate>

@property BOOL isMultiMode;

@end
