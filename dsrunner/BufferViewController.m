//
//  BufferViewController.m
//  dsrunner
//
//  Created by Cui Wei on 4/19/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "BufferViewController.h"


#define GO_TO_MAIN_PAGE_VC @"EXIT_BUFFER_VC"
#define USER_CALCEL_GC_LOGIN_TITLE @"You cancelled Log in\n or disabled Game Center?"

@interface BufferViewController ()

@property GameCenterHelper *myGCHelper;
@property BOOL canGoToNextStage;
@property NSTimer *myTimer;
@end

@implementation BufferViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myGCHelper = [GameCenterHelper sharedInstance];
    self.myGCHelper.GKLogInVCControllerDelegate = self;
    [self authenticateLocalPlayer];
    self.canGoToNextStage = NO;
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(goHome)
                                                      userInfo:Nil
                                                       repeats:YES];
    
    
}


- (void)userDidCancelLogIn{
//EFFECT: prompt alert to inform user game center not available due to their cancellation
    
    UIAlertView * doesNotSupportGameCenter = [[UIAlertView alloc] initWithTitle:USER_CALCEL_GC_LOGIN_TITLE
                                                                        message:@"You can still play single player mode. But to engage in multiplayer mode, you need to sign in to Game Center to have more fun"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Take me to Log in",Nil];
    
    
    [doesNotSupportGameCenter show];
    

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    

    
    if([alertView.title isEqualToString:USER_CALCEL_GC_LOGIN_TITLE]){
        if(buttonIndex == 0){
            self.canGoToNextStage = YES;
        }
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
    
}

-(void)goHome{
//EFFECT: segue to home view controller
    
    if(self.canGoToNextStage || self.myGCHelper.userAuthenticated){
        [self.myTimer invalidate];
        self.myTimer = Nil;
        self.myGCHelper.GKLogInVCControllerDelegate = Nil;
        [self performSegueWithIdentifier:GO_TO_MAIN_PAGE_VC sender:Nil];
    }
    
}

-(void)authenticateLocalPlayer{
    
    
    [self.myGCHelper authenticateLocalUser];
    
}

@end
