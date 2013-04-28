//
//  GameCenterHelper.m
//  DSRunner-Network
//
//  Created by Cui Wei on 3/30/13.
//  Copyright (c) 2013 Cui Wei. All rights reserved.
//

#import "GameCenterHelper.h"
#import "AppDelegate.h"


@interface GameCenterHelper ()

@property (readwrite) BOOL gameCenterAvailable;
@property (readwrite) BOOL userAuthenticated;
@property (readwrite) BOOL matchStarted;
@property (readwrite) NSMutableDictionary *playersDict;
@property (readwrite) GKMatch *match;

@end


@implementation GameCenterHelper

static GameCenterHelper *sharedHelper = nil;
    
#pragma mark initialization

- (id)init {
    
    if ((self = [super init])) {
        
        self.gameCenterAvailable = [self isGameCenterAvailable];

        if (self.gameCenterAvailable) {
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    
    return self;
}

+ (GameCenterHelper *) sharedInstance {
    
    if (!sharedHelper) {
        sharedHelper = [[GameCenterHelper alloc] init];
    }
    return sharedHelper;
    
}


#pragma mark checking GameCenter Availablity

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}


#pragma mark authentication

- (void)authenticateLocalUser {
    
    if (!self.gameCenterAvailable){
        
        UIAlertView * doesNotSupportGameCenter = [[UIAlertView alloc] initWithTitle:@"Oops, unsupported system version :("
                                                                            message:@"Game Center is not supported on your device"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Got it."
                                                                  otherButtonTitles:nil];
        [doesNotSupportGameCenter show];
        
        return;
    }
    
    NSLog(@"Authenticating local user...");
    
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController* viewcontroller, NSError *error) {
        
        if (!error && viewcontroller){
            AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
            [delegate.window.rootViewController presentViewController:viewcontroller animated:YES completion:nil];
        }
        else{
            
            GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
            
            if (!localPlayer.isAuthenticated){
                [self.GKLogInVCControllerDelegate userDidCancelLogIn];
            }
        }
    }];
}


-(NSString*)getMyNickName{
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    return localPlayer.alias;
    
}



- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && ! self.userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        self.userAuthenticated = YES;
        [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            NSLog(@"Received invite");
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            assert(self.GKGameMatchDelegate != Nil);
            [self.GKGameMatchDelegate inviteReceived];
            
        };
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && self.userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        self.userAuthenticated = NO;
    }
    
}


- (void)lookupPlayers {

    if(self.match.playerIDs.count == 1){
       NSLog(@"Looking up %d player...",  self.match.playerIDs.count);
    }
    else{
       NSLog(@"Looking up %d players...", self.match.playerIDs.count);
    }
    
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            self.matchStarted = NO;
            [self.GKGameMatchDelegate matchEnded];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            
            for (GKPlayer *player in players) {
                
                [self.playersDict setObject:player forKey:player.playerID];
                
            }
            
            // Notify delegate match can begin
            self.matchStarted = YES;
            [self.GKGameMatchDelegate matchStarted];
            
                
        }
    }];
    
    
    
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
    self.match = theMatch;
    self.match.delegate = self;
    if (!self.matchStarted && self.match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}


#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    
    
    if (self.match != theMatch){
        NSLog(@"not same match");
        return;
    }
    
    assert(self.GKGameMatchDelegate != Nil);
    
    [self.GKGameMatchDelegate match:theMatch didReceiveData:data fromPlayer:playerID];
    
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    if (self.match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!self.matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            self.matchStarted = NO;
            [self.GKGameMatchDelegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (self.match != theMatch) return;
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    self.matchStarted = NO;
    [self.GKGameMatchDelegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    self.matchStarted = NO;
    [self.GKGameMatchDelegate matchEnded];
}


#pragma mark Finding match

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate {

    
    if (!self.gameCenterAvailable){
        
        UIAlertView * doesNotSupportGameCenter = [[UIAlertView alloc] initWithTitle:@"Oops, match making failed :("
                                                                            message:@"Game Center is not supported on your device"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Got it."
                                                                  otherButtonTitles:nil];
        
        
        [doesNotSupportGameCenter show];
        
        return;
    }

    
    self.matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.GKGameMatchDelegate = theDelegate;
    
    if (self.pendingInvite != nil) {
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:self.pendingInvite];
        mmvc.matchmakerDelegate = self;
        [self.presentingViewController presentViewController:mmvc animated:YES completion:Nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        request.playersToInvite = self.pendingPlayersToInvite;
        
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        
        [self.presentingViewController presentViewController:mmvc animated:YES completion:Nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    }
    
    
    
    
    
}





@end
