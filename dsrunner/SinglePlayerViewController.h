//
//  SinglePlayerViewController.h
//  dsrunner
//
//  Created by sai on 3/28/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GameCenterHelper.h"
#import "PacketRenderer.h"
#import "PacketMaker.h"
#import "GameControllerDelegate.h"

/**OVERVIEW:
 * This class is handling both single-player game and multiplayer game.
 * It allows users to draw lines on its view to play the game.
 * It is the delegate of GameCenterHelper and PackSender and PecketRender
 * It is supported by the physical engine in another class.
 * NSTimer is not used in this class but CADisplaylink
 */

@interface SinglePlayerViewController : UIViewController<GCHelperDelegate, RenderDelegate, MakerDelegate, GameControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIView *board;
@property (weak, nonatomic) IBOutlet UIView *endingPopup;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIImageView *loseImage;
@property (weak, nonatomic) IBOutlet UIView *multiBlinkLayer;
@property (weak, nonatomic) IBOutlet UIView *multiplayerView;
@property (weak, nonatomic) IBOutlet UIView *multiViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *BlinkLayer;

- (IBAction)pressSwitchButton:(id)sender;
//EFFECT: switch ink between red/green
- (IBAction)pause:(id)sender;
//EFFECT: pause the game
@property BOOL isMultiMode;

@property (nonatomic) GameCenterHelper *GCHelper;

@end
