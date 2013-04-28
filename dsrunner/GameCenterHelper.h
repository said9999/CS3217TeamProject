//
//  GameCenterHelper.h
//  DSRunner-Network
//
//  This is the class that will enable game center.
//  Its job is to (1) authenticate the local player during in multiplayer mode
//                (2) find a match via game center.
//
//  Created by Cui Wei on 3/30/13.
//  Copyright (c) 2013 Cui Wei. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>




@protocol GCHelperDelegate
 /***************************************************************************
 * This is the protocol that our any user of this class should conform.     *
 * The GameCenterHelper object will call its delegate, which is essentially *
 * the class that uses this GameCenterHelper object to perform centain      *
 * actions when the following events happen: (1)game match starting;        *
 * (2)game match ending; (3)receive data from the other party               *
 ****************************************************************************/

- (void)matchStarted;
//EFFECT: inform the delegate that a match has been established, actions should be taken
- (void)matchEnded;
//EFFECT: inform the delegate that the current established match has been disconnected, actions should be taken
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
//EFFECT: inform the delegate that data from the matched player have been received, actions should be taken
- (void)inviteReceived;
//EFFECT: inform the delegate that a invite froma game center frined has been received, actions should be taken

@end

@protocol GCHelperLogInDelegate
//This is the protocol defined only for the buffer view controller, for the buffer view controller is responsoble
//for user log in

- (void)userDidCancelLogIn;
//EFFECT: inform the delegate that the automatic game center log in is cancelled by the user, actions should be taken

@end



//OVERVIEW: This is the class implementing all the necessary method for using game center
@interface GameCenterHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>


@property (readonly) NSMutableDictionary *playersDict;
//contains alias based on player's unique Game center ID

@property (readonly) BOOL gameCenterAvailable;
@property (readonly) BOOL userAuthenticated;

@property UIViewController *presentingViewController;
@property (readonly) GKMatch *match;
@property (readonly) BOOL matchStarted;

@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;

@property (weak) id <GCHelperDelegate> GKGameMatchDelegate;
@property (weak) id <GCHelperLogInDelegate> GKLogInVCControllerDelegate;




+ (GameCenterHelper *)sharedInstance;
// EFFECT:Returns a shared instance that can authenticate the  
// local user and find a match to start a game.                                 
 

- (void)authenticateLocalUser;
//EFFECT:authenticate the local player 
 

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate;
// EFFECT:find a match in multiplayer mode.

-(NSString*)getMyNickName;
//EFFECT:return current local player's game center nickname.


 

@end
