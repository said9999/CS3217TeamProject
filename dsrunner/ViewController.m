//
//  ViewController.m
//  dsrunner
//
//  Created by sai on 3/27/13.
//  @Author: Cui Wei
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ViewController.h"
#import "GameLevel.h"
#import "AudioPlayer.h"
#import "AppDelegate.h"

#define SEGUE_FROM_MAIN_VIEW_CONTROLLER_TO_PLAY_SCENE_VIEW_CONTROLLER @"MAIN_TO_PLAYSCENE"
#define CANNOT_JOIN_GAMECENTER @"Cannot join multiplayer mode :("
#define CANNOT_JOIN_GAMECENTER_MESSAGE @"It seems that you are not authenticated\n into Game Center yet\n Want more fun?\n Go to Game Center To Log in!"
#define TAKE_TO_GAMECENTER @"Cool, take me there"


@interface ViewController (){
    AVAudioPlayer * player;
    NSNumber *seedToPlayerController;
}

@property (readwrite) int levelSelected;
@property GameCenterHelper *myGCHelper;
@property BOOL isMultiPlayerMode;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    player = [AudioPlayer playAudio:BACKGROUND_MUSIC audioFormat:WAV_FORMAT];
    player.numberOfLoops = INFINITE_LOOP;
    [player play];
    
    self.myGCHelper = [GameCenterHelper sharedInstance];
    
    if(self.myGCHelper.match)
        [self.myGCHelper.match disconnect];//disconnect any existing connection to prepare for new connection
    
    self.myGCHelper.GKGameMatchDelegate = self;
    
    self.isMultiPlayerMode = NO;
    self.levelSelected = arc4random();
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    [player stop];

    if ([segue.identifier isEqualToString:SEGUE_FROM_MAIN_VIEW_CONTROLLER_TO_PLAY_SCENE_VIEW_CONTROLLER]) {


        if(self.isMultiPlayerMode)
            [segue.destinationViewController performSelector:@selector(setMultiplayerMode:) withObject:
             seedToPlayerController];
        
    }

}


- (IBAction)multiplayerButtonPressed:(id)sender {


    if(self.myGCHelper.userAuthenticated){
        [self findMatch];
    }
    else{

        UIAlertView * autheticationFailed = [[UIAlertView alloc] initWithTitle:CANNOT_JOIN_GAMECENTER
                                                                       message:CANNOT_JOIN_GAMECENTER_MESSAGE
                                                                      delegate:self
                                                             cancelButtonTitle:CANCEL_BUTTON
                                                             otherButtonTitles:TAKE_TO_GAMECENTER,nil];
        [autheticationFailed show];

        return;

    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if([alertView.title isEqualToString:CANNOT_JOIN_GAMECENTER] && buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }


}


-(void)findMatch{

    AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    assert(delegate.window.rootViewController!=Nil);
    [self.myGCHelper findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.window.rootViewController delegate:self];
}

-(void)sendMap{
    MapData myMapData = {GAMEDATA_MAP,self.levelSelected};
    NSMutableData *myData = [NSMutableData dataWithBytes:&myMapData length:sizeof(MapData)];
    NSError *error;
    [self.myGCHelper.match sendDataToAllPlayers:myData
                                   withDataMode:GKMatchSendDataReliable
                                          error:&error];
}

- (void)matchStarted{

    self.isMultiPlayerMode = YES;
    [self sendMap];

}

- (void)matchEnded{

    NSLog(@"Matched Ended");

}

-(void)goToMultiPlayerMode{
    [self performSegueWithIdentifier:SEGUE_FROM_MAIN_VIEW_CONTROLLER_TO_PLAY_SCENE_VIEW_CONTROLLER sender:Nil];

}

-(void)inviteReceived{

    [self multiplayerButtonPressed:Nil];

}



- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{

    int type;
    int seed;
    [data getBytes:&type range:NSMakeRange(0, sizeof(int))];
    
    if (type != GAMEDATA_MAP) return;

    [data getBytes:&seed range:NSMakeRange(sizeof(int)*1, sizeof(int))];
    
    if(seed > self.levelSelected){

        self.levelSelected = seed;
    }

    seedToPlayerController = [NSNumber numberWithInt:self.levelSelected];

    UIView *coverView = [[UIView alloc] initWithFrame:self.view.frame];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.5;
    [self.view addSubview:coverView];


    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    activityView.color = [UIColor whiteColor] ;
    [activityView startAnimating];
    [coverView addSubview:activityView];

    [self performSelector:@selector(goToMultiPlayerMode) withObject:nil afterDelay:3];
    
}


@end
