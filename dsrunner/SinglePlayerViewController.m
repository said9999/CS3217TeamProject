//
//  SinglePlayerViewController.m
//  dsrunner
//
//  Created by sai on 3/28/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "SinglePlayerViewController.h"
#import "ViewController.h"
#import "AudioPlayer.h"
#import "GameGround.h"
#import "GameLevel.h"
#import "GameDestination.h"
#import "GameEnemy.h"
#import "Line.h"
#import "PacketMaker.h"
#import "GameInk.h"
#import "Game.h"

#define LOSEGAME_MUSIC @"tryharder"
#define WINGAME_MUSIC @"victory"
#define GETINK_MUSIC @"getink"
#define GETGIFT_MUSIC @"trigger"
#define SWITCH_BUTTON_RADIUS 40
#define GIFT_IMG @"questionMark.png"
#define DESTINATION_RADIUS 10
#define MULTIPLYRATIO 2
#define READ_LEVEL_FORMAT @"level%d.xml"
#define REDBUTTON_IMG @"redbutton.png"
#define GREENBUTTON_IMG @"greenbutton.png"
#define GREYBUTTON_IMG @"greybutton.png"
#define HORSEWIDTH 110
#define HORSEHEIGHT 90
#define TOPBOARD_WIDTH 1

#define UPSIDEDOWN_DELAY_TIME 2
#define TRANSFORM_RATIO_X 1
#define TRANSFORM_RATIO_Y -1
#define NO_INK_DELAY_TIME 1
#define BLINK_DELAY 1
#define STUCK_RUNNER_DELAY 3
#define INK_DIVIDE_RATIO 5

#define TIMER_INTERVAL 2


@interface SinglePlayerViewController() {
    Game *game;
    
    CADisplayLink *displayLink;
    
    UIView *redInkView;
    UIView *greenInkView;
    UIView *redInkStand;
    UIView *greenInkStand;
    UIView *tickView;
    
    NSMutableArray *randomGiftLocationList;
    
    AVAudioPlayer *paintingPlayer;
    AVAudioPlayer *runningPlayer;
    AVAudioPlayer *warnningPlayer;
    AVAudioPlayer *playerBackgroundPlayer;
    AVAudioPlayer *victoryPlayer;
    AVAudioPlayer *losePlayer;
    AVAudioPlayer *getInkplayer;
    AVAudioPlayer *triggerPlayer;
    int boardOffset;
    UIPanGestureRecognizer *pan;
    UIPanGestureRecognizer *buttonPan;
    
    BOOL isPaused;
    
    GameRunner *runner;
    GameLevel *level;

    BOOL hasReceivedMap;
    BOOL hasSendMap;
    
    int myMapSeed;
    int sendRate;
    PacketMaker *packetMaker;
    PacketRenderer *packetRenderer;
    UIImage *redButton;
    UIImage *greenButton;
    UIImage *greyButton;
    
}

- (IBAction)refresh:(id)sender;
//EFFECT: replay and clean up the game
@property NSString* selectedGameLevel;
@end


@implementation SinglePlayerViewController


/**EFFECT:
 * Set up all necessary data before playing a game
 * and  distribute setup tasks into other small methods.
 */
- (void)setup {
    [self setupPlayerMode];
    
    [self setupPacketManage];
    
    [self prepareCanvas];
    
    [self setupGameObjects];
    
    [game startGameObjectsAnimation];
    
    [self setupTimer];
    
    [self addGestureToSwitchButtonAndCanvas];
    
    [self setupInk];
    
    [self setupButtonImgs];
    
    [self setupAudios];

}

/**EFFECT:
 * init basic properties : gamelevel, gamehandler and triggerhandler
 */
- (void)setupPlayerMode {
    game = [[Game alloc] initWithController:self];
    randomGiftLocationList = [NSMutableArray array];
    level = [[GameLevel alloc] initWithLevel:self.selectedGameLevel];
    self.board.frame = CGRectMake(0, 0, level.width, BOARD_HEIGHT);
    /** 
     *  Pause button and multiplayer view are hidden
     *  if it's not a multiplayer game
     */
    if (!self.isMultiMode) {
        [self.GCHelper.match disconnect];
        self.multiViewContainer.hidden = YES;
    }else{
        self.multiBlinkLayer.hidden = YES;
        self.pauseButton.hidden = YES;
    }
}

/** EFFECT:
 *  Prepare packet sending and receiving
 */
- (void)setupPacketManage{
    if (!self.isMultiMode) return;
    
    sendRate = 0;
    packetMaker = [PacketMaker sharedInstance];
    packetMaker.delegate = self;
   
    packetRenderer = [PacketRenderer sharedInstance];
    packetRenderer.delegate = self;
    [packetRenderer refreshData];//get data from its delegate
}

- (void)prepareCanvas{
    if (self.isMultiMode) {
        [self createMultiPlayerWindow];
    }
    
    isPaused = NO;
    self.endingPopup.hidden = YES;
    boardOffset = 0;
    [self hideBlinkLayer:self.BlinkLayer];
}

/**EFFECT:
 * By loading models from the GameLevel, 
 * Game Objects are added into gamearea.
 */
- (void)setupGameObjects {
    [self addTopBoard];
    for (GameModel *model in level.models) {
        RectGameObject *obj;
        
        //trigger cannot be added if the game is in single-player mode
        if ([self isNotProperToAddGift:model]) {
            continue;                                                      
        }
        
        obj = [self getGameObjectWithModel:model];
        [self resizeView:obj.view WithObject:obj];
        
        if (obj.model.modelType != GameModelGift) {
            [self addGameObjectToGameArea:obj];
        }
    }
    
    // Enable triggers if it's a multiplayer game
    if (self.isMultiMode) {
        [self randomAssignGiftPosition];
    }
    
    [self setupStickManWithCenter:level.startPoint speed:level.speed];
}


- (void)setupTimer {
    displayLink = [CADisplayLink displayLinkWithTarget:self
                                              selector:@selector(step)];
    displayLink.frameInterval = TIMER_INTERVAL;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)addGestureToSwitchButtonAndCanvas{
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(pan:)];
    [self.board addGestureRecognizer:pan];
    
    buttonPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(buttonPan:)];
    [self.switchButton addGestureRecognizer:buttonPan];
}

- (void)setupInk {
    game.maxInkPoint = level.ink;
    game.inkPoints[RED_INK] = game.inkPoints[GREEN_INK] = level.ink;
    
    [self addRedInkAndStandView];
    [self addGreenInkAndStandView];
    [self addTickView];
}

/**EFFECT:
 * Enable a button to switch redink/greenink for user's convenience
 */
- (void)setupButtonImgs{
    redButton = [UIImage imageNamed:REDBUTTON_IMG];
    greenButton = [UIImage imageNamed:GREENBUTTON_IMG];
    greyButton = [UIImage imageNamed:GREYBUTTON_IMG];
    self.switchButton.backgroundColor = [UIColor colorWithPatternImage:redButton];
}

- (void)setupAudios {
    warnningPlayer = [AudioPlayer playAudio:WARNING_MUSIC //no ink
                                audioFormat:MP3_FORMAT];
    
    paintingPlayer = [AudioPlayer playAudio:CHALK_MUSIC  //painting lines
                                audioFormat:MP3_FORMAT];
    
    runningPlayer = [AudioPlayer playAudio:RUNNING_MUSIC //step sound
                               audioFormat:MP3_FORMAT];
    [runningPlayer setVolume:RUNNER_VOLUMN];
    
    playerBackgroundPlayer = [AudioPlayer playAudio:PLAYER_BACKGROUND_MUSIC 
                                        audioFormat:MP3_FORMAT];
    playerBackgroundPlayer.numberOfLoops = INFINITE_LOOP;
    
    losePlayer = [AudioPlayer playAudio:LOSEGAME_MUSIC audioFormat:MP3_FORMAT];
    
    victoryPlayer = [AudioPlayer playAudio:WINGAME_MUSIC audioFormat:MP3_FORMAT];
    victoryPlayer.numberOfLoops = 0;
    
    getInkplayer = [AudioPlayer playAudio:GETINK_MUSIC audioFormat:MP3_FORMAT]; //get a ink supply
    
    triggerPlayer = [AudioPlayer playAudio:GETGIFT_MUSIC audioFormat:MP3_FORMAT]; //enable a trigger
    
    [playerBackgroundPlayer play];
}

/**EFFECT:
 * Handle path drawing
 */
- (void)pan:(UIPanGestureRecognizer *)gesture {
    if (game.currentInkPoints == 0) {
        [self didUseUpInk];
        return;
    }
    
    if (![paintingPlayer isPlaying]) {
        [paintingPlayer play];
    }
    
    CGPoint loc = [gesture locationInView:self.board];
    CGPoint translation = [gesture translationInView:self.board];
    CGPoint prevPoint = CGPointMake(loc.x - translation.x, loc.y - translation.y);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self startDrawPath:prevPoint];
    }
    
    double len = sqrt(translation.x * translation.x + translation.y * translation.y);
    if (len > MIN_LINE_LEN || (gesture.state == UIGestureRecognizerStateEnded && len > MIN_LINE_LEN_END)) {
        Line *line = [Line lineWithX1:prevPoint.x y1:BOARD_HEIGHT - prevPoint.y x2:loc.x y2:BOARD_HEIGHT - loc.y];
        __block BOOL collision = NO;
        [game.world findCollisionsFor:line in:game.world.foreground at:0 do: ^(CollisionInfo *c) {
            collision = YES;
        }];
        
        if (collision) {
            [self endDrawPath];
        } else {
            game.currentInkPoints = MAX(0, game.currentInkPoints - len / INK_DIVIDE_RATIO);
            GamePath *path = game.paths.lastObject;
            [path.lines addObject:line];
            [path addLineTo:CGPointMake(loc.x, loc.y)];
            
            [game.world addBodyToBackground:line];
            game.bodyToGameObjectDict[line] = path;
            
            [gesture setTranslation:CGPointMake(0, 0) inView:self.board];
        }
    }
    
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self endDrawPath];
    }
}

- (void)buttonPan:(UIPanGestureRecognizer*)gesture{
    [self enableMoveButton:gesture];
    [self contrainButtonLocation:gesture];
}

/**EFFECT:
 * Stop timer and remove resources
 */
- (void)endGame {
    if (self.isMultiMode) {
        self.replayButton.hidden = YES;
    }
    [playerBackgroundPlayer stop];
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [game end];
    [self.board removeGestureRecognizer:pan];
    [self.switchButton removeGestureRecognizer:buttonPan];
    pan = nil;
    buttonPan = nil;
    runner = nil;
}

/**EFFECT:
 * This method is called when a player wins the game
 */
- (void)clearGame {
    [victoryPlayer play];
    
    //notice the opponent if in multiplayer mode
    if (self.isMultiMode) {
        NSData *data = [packetMaker sendPacketWithType:GAMEDATA_WIN];
        [self sendToGameCenter:data];
    }
    self.loseImage.hidden = YES;
    self.endingPopup.hidden = NO;
    [self endGame];
}

/**EFFECT:
 * This method is called when a player fails the game
 */
- (void)failGame {
    [losePlayer play];
    
    //notice the opponent if in multiplayer mode
    if (self.isMultiMode) {
        NSData *data = [packetMaker sendPacketWithType:GAMEDATA_DIE];
        [self sendToGameCenter:data];
    }
    self.loseImage.hidden = NO;
    self.endingPopup.hidden = NO;
    [self endGame];
}


- (void)enableMoveButton:(UIPanGestureRecognizer *)gesture{
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:gesture.view.superview];
}

/**EFFECT:
 * This method gaurantee switch button won't get outside of the screen
 */
- (void) contrainButtonLocation:(UIPanGestureRecognizer *)gesture{
    if (gesture.view.center.x <= SWITCH_BUTTON_RADIUS) {
        gesture.view.center = CGPointMake(SWITCH_BUTTON_RADIUS, gesture.view.center.y);
    }
    if (gesture.view.center.x >= SCREEN_WIDTH-SWITCH_BUTTON_RADIUS) {
        gesture.view.center = CGPointMake(SCREEN_WIDTH-SWITCH_BUTTON_RADIUS, gesture.view.center.y);
    }
    
    if (gesture.view.center.y >= BOARD_HEIGHT-SWITCH_BUTTON_RADIUS) {
        gesture.view.center = CGPointMake(gesture.view.center.x, BOARD_HEIGHT-SWITCH_BUTTON_RADIUS);
    }
    
    if (gesture.view.center.y <= SWITCH_BUTTON_RADIUS) {
        gesture.view.center = CGPointMake(gesture.view.center.x, SWITCH_BUTTON_RADIUS);
    }
}

/**EFFECT:
 * View is resized according to the size in the object's model
 */
- (void)resizeView:(UIView*)view WithObject:(RectGameObject*)obj{
    view.frame = CGRectMake(0, 0, obj.model.size.width, obj.model.size.height);
    view.center = CGPointMake(obj.model.center.x + obj.viewOffset.x, BOARD_HEIGHT - (obj.model.center.y + obj.viewOffset.y));
}

/**EFFECT:
 * This method is called when in multiplayer mode, 
 * it assigns gift(triggers) randomly in the map
 */
- (void)randomAssignGiftPosition{
    if (randomGiftLocationList.count == 0)
        return;
    
    int seed = arc4random_uniform(randomGiftLocationList.count);
    RectGameObject *gift = [randomGiftLocationList objectAtIndex:seed];
    
    UIView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:GIFT_IMG]];
    
    gift.view = view;
    [self resizeView:gift.view WithObject:gift];
    [game addGameObjectToBackground:gift];
}

- (void)setupStickManWithCenter:(CGPoint)center speed:(int)speed {
    GameModel *m = [[GameModel alloc] initWithType:GameModelRunner
                                             center:center
                                              size:CGSizeMake(RUNNER_BODY_WIDTH, RUNNER_BODY_HEIGHT)];
    runner = [[GameRunner alloc] initWithModel:m];
    runner.speed = speed;
    [game addGameObjectToForeground:runner];
}

/**EFFECT:
 * This method is called when in multiplayer mode
 * It creates a small view on the right top position of the main screen
 */
- (void)createMultiPlayerWindow{
    CGRect oframe = CGRectMake(0, 0, level.width, BOARD_HEIGHT);
    self.multiplayerView.frame = CGRectMake(0, 0, oframe.size.width * MULTIVIEW_RATIO,oframe.size.height * MULTIVIEW_RATIO);
    [packetRenderer refreshData];
    [packetRenderer renderMap];
}



- (void)addGameObjectToGameArea:(RectGameObject *)obj{
    if (obj.model.modelType == GameModelDestination) {
        obj.model.size = CGSizeMake(DESTINATION_RADIUS, DESTINATION_RADIUS);
        obj.body.width = obj.body.height = DESTINATION_RADIUS;
    }
    
    if (obj.model.modelType != GameModelEnemy) {//moveing objects are added in to foreground
        [game addGameObjectToBackground:obj];
    } else {
        [game addGameObjectToForeground:obj];
    }
}

- (RectGameObject *)getGameObjectWithModel:(GameModel *)model{
    RectGameObject *obj;
    UIView *view = [[UIView alloc] init];
    
    switch (model.modelType) {
        case GameModelGround:
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BRICK_GROUND_IMAGE]];
            obj = [[GameGround alloc] initWithModel:model];
            break;
            
        case GameModelDestination:
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SUN_DESTINATION]];
            obj = [[GameDestination alloc] initWithModel:model];
            break;
            
        case GameModelEnemy:
            view = [FrameConstructor horseFrames];
            obj = [[GameEnemy alloc] initWithModel:model];
            break;
        case GameModelGreenInk:
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:GREENINK_STAND_IMAGE]];
            obj = [[GameInk alloc] initWithModel:model];
            
            break;
        case GameModelRedInk:
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:REDINK_STAND_IMAGE]];
            obj = [[GameInk alloc] initWithModel:model];
            break;
        case GameModelGift:
            obj = [[GameInk alloc] initWithModel:model];
            [randomGiftLocationList addObject:obj];
            break;
        default:
            break;
    }
    obj.view = view;
    
    return obj;
}



- (UIView*)getViewWithImgName:(NSString*)name AndFrame:(CGRect)frame{
    UIView *view = [[UIView alloc] init];
    
    UIImage *img = [UIImage imageNamed:name];
    view.backgroundColor = [UIColor colorWithPatternImage:img];
    view.frame = frame;
    
    return view;
}

- (void)addRedInkAndStandView{
    redInkView = [[UIView alloc] init];
    redInkView = [self getViewWithImgName:REDINK_IMAGE
                                 AndFrame:CGRectMake(RED_INK_POS_X,
                                                     RED_INK_POS_Y,
                                                     INK_WIDTH,
                                                     INK_HEIGHT)];
    [self.backgroundView addSubview:redInkView];
    
    
    redInkStand = [[UIView alloc] init];
    redInkStand = [self getViewWithImgName:REDINK_STAND_IMAGE
                                  AndFrame:CGRectMake(RED_INK_STAND_POS_X,
                                                      RED_INK_STAND_POX_Y,
                                                      INK_STAND_WIDTH,
                                                      INK_STAND_HEIGHT)];
    
    [self.backgroundView addSubview:redInkStand];

}

- (void)addGreenInkAndStandView{
    greenInkView = [[UIView alloc] init];
    greenInkView = [self getViewWithImgName:GREENINK_IMAGE
                                   AndFrame:CGRectMake(GREEN_INK_POS_X,
                                                       GREEN_INK_POS_Y,
                                                       INK_WIDTH,
                                                       INK_HEIGHT)];
    [self.backgroundView addSubview:greenInkView];
    
    greenInkStand = [[UIView alloc] init];
    greenInkStand = [self getViewWithImgName:GREENINK_STAND_IMAGE
                                    AndFrame:CGRectMake(GREEN_INK_STAND_POS_X,
                                                        GREEN_INK_STAND_POX_Y,
                                                        INK_STAND_WIDTH,
                                                        INK_STAND_HEIGHT)];
    [self.backgroundView addSubview:greenInkStand];

}



- (void) addTickView{
    [tickView removeFromSuperview];
    CGRect frame;
    if (game.currentInkType == RED_INK) {
        frame = CGRectMake(TICK_POS_X, TICK_POS_Y_RED, TICK_WIDTH, TICK_HEIGHT);
    }else{
        frame = CGRectMake(TICK_POS_X, TICK_POS_Y_GREEN, TICK_WIDTH, TICK_HEIGHT);
    }
    
    tickView = [[UIView alloc] init];
    tickView = [self getViewWithImgName:TICK_IMAGE AndFrame:frame];
    [self.backgroundView addSubview:tickView];
}

/**EFFECT:
 * This method is called when the user want to switch the ink to redink
 * by pressing the button
 */
-(void)redInkSwitch{
    game.currentInkType = RED_INK;
    [self addTickView];
}

/**EFFECT:
 * This method is called when the user want to switch the ink to greenink
 * by presssing the button
 */
-(void)greenInkSwitch{
    game.currentInkType = GREEN_INK;
    [self addTickView];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //go back to main viewcontroller if the homebutton is pressed
    //clean up all resources and end the game
    [losePlayer stop];
    
    if ([segue.identifier isEqualToString:HOMESCREEN_IDENTIFIER]) {
         if (self.isMultiMode){
            [self.GCHelper.match disconnect];
            self.isMultiMode = NO;
        }
        [self endGame];
    }
    [self cleanUp];
}

/**EFFECT:
 * This method is called when a user get a trigger
 * the packetMaker will send a gift packet to the opponent
 * to enable special effect
 */
- (void)sendGiftPacket{
    NSData *packet = [packetMaker sendPacketWithType:GAMEDATA_GIFT];
    [self sendToGameCenter:packet];
}

/**EFFECT:
 * This method is called repeately by the timer to renew the pysical world.
 */
- (void)step {
    if (isPaused) return;
    
    //if in multiplayer mode, send a packet every two frames
    if (self.isMultiMode) {
        [self sendPacketEveryTwoFrame];
    }
    
    //if the runner cross the threshold on the map, the screen forward right
    if (runner.body.center.x > MOVE_BOARD_THRESHOLD + boardOffset) {
        [self forwardScreen];
    }
    
    [game step:1 / FPS];
    [self updateInkPoints];
    [self updateGameObjectViews];
    
    //if runner is alive and is running on the ground, running music continue playeing
    if (![runningPlayer isPlaying] && runner.body.isOnGround) {
        [runningPlayer play];
    }
    
    if (runner.isDead)
        [self failGame];
}

- (void)sendPacketEveryTwoFrame{
    if (sendRate == 0){
        NSMutableData *packet = (NSMutableData*)[packetMaker sendPacketWithType:GAMEDATA_FOREGROUND];
        [self sendToGameCenter:packet];
    }
    sendRate = (sendRate + 1) % 2;
}

- (void)updateInkPoints{
    for (int i = 0; i < KINDS_OF_INK; i++) {
        double widthPercentage = game.inkPoints[i] * 1.0 / game.maxInkPoint;
        double width = INK_WIDTH * widthPercentage;
        UIView *view = i == RED_INK ? redInkView : greenInkView;
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
    }
}

- (void)updateGameObjectViews{
    for (RectGameObject *obj in game.foregroundObjects) {
        Rectangle *body = obj.body;
        UIView *view = obj.view;
        view.center = CGPointMake(body.center.x + obj.viewOffset.x, BOARD_HEIGHT - (body.center.y + obj.viewOffset.y));
    }
}

/**EFFECT:
 * This method is called when the screen is forward, to make sure the 
 * stick man cannot run back
 */
- (void)addLeftBorder{
    GameModel *m = [[GameModel alloc] initWithType:GameModelGround
                                            center:CGPointMake(boardOffset - DEVIATION, BOARD_HEIGHT)
                                              size:CGSizeMake(LEFT_BOARDER_WIDTH, BOARD_HEIGHT * MULTIPLYRATIO)];
    GameGround *g = [[GameGround alloc] initWithModel:m];
    [game addGameObjectToBackground:g];
}

/**EFFECT:
 * This method is called when the game start to forbid the runner run out of the screen
 */
- (void)addTopBoard{
    GameModel *m = [[GameModel alloc] initWithType:GameModelGround
                                            center:CGPointMake(level.width/2, BOARD_HEIGHT)
                                              size:CGSizeMake(level.width, TOPBOARD_WIDTH)];
    GameGround *g = [[GameGround alloc] initWithModel:m];
    [game addGameObjectToBackground:g];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
	// Do any additional setup after loading the view.
}

/**EFFECT:
 * This method is called when the stick man crosses a threshold on the map
 */
- (void)forwardScreen{
    int offset = MIN(BOARD_UNIT_OFFSET,
                     self.board.frame.size.width - boardOffset - self.board.superview.frame.size.width);
    if (offset > 0) {
        [self endDrawPath];
        isPaused = YES;
        boardOffset += offset;
        [self addLeftBorder];
        [UIView animateWithDuration:RUNNER_WALK_DURATION animations:^{
            self.board.center = CGPointMake(self.board.center.x - offset, self.board.center.y);
        } completion:^(BOOL finished) {
            isPaused = NO;
        }];
    }
}

- (void)startDrawPath:(CGPoint)point {
    GamePath *path = [game startDrawPath:point];
    path.view.frame = CGRectMake(boardOffset, 0, self.board.superview.frame.size.width, BOARD_HEIGHT);
}

- (void)endDrawPath {
    [game endDrawPath];
    pan.enabled = NO;
    pan.enabled = YES;
}

- (BOOL)isNotProperToAddGift:(GameModel*) model{
    if(!self.isMultiMode &&
       model.modelType == GameModelGift)
        return true;
    return false;
}

- (IBAction)pause:(id)sender {
    isPaused = !isPaused;
    
    if (isPaused) {
        pan.enabled = NO;
        [game stopGameObjectsAnimation];
    } else {
        pan.enabled = YES;
        [game startGameObjectsAnimation];
    }
}

- (void)viewDidUnload {
    [self endGame];
    [self setMenuButton:nil];
    [self setEndingPopup:nil];
    [self setLoseImage:nil];
    [super viewDidUnload];
}

/**EFFECT:
 * This method is called in the multiplayer mode,
 * it's used to init necessary data before playing
 * 
 * @para seed :is the map seed decided to use in the game
 */
-(void)setMultiplayerMode:(NSNumber *)seed{
    int seedValue = [seed intValue];
    int levelSeed = (seedValue>=0)?seedValue%4+1:(-seedValue)%4+1;
    NSString *levelString = [NSString stringWithFormat:READ_LEVEL_FORMAT,levelSeed];
    self.GCHelper = [GameCenterHelper sharedInstance];
    self.GCHelper.GKGameMatchDelegate = self;
    self.isMultiMode = YES;
    self.selectedGameLevel = levelString;
}

- (void)sendToGameCenter:(NSData*)data{
    NSError *error;
    [self.GCHelper.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
}

- (void)matchEnded{
    [self performSegueWithIdentifier:HOMESCREEN_IDENTIFIER sender:Nil];
}
/**EFFECT:
 * This method is invoked when a data packet is received
 */
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    [packetRenderer receivePacket:data];
}

- (void)matchStarted{
    
}
-(void)inviteReceived{
    
}

/**EFFECT:
 * This method is called when need to replay the game
 */
- (IBAction)refresh:(id)sender {
    [self cleanUp];
    [self setup];
}

/**
 * The following methods are called in the multiplayer mode when a trigger is enable by another player
 * special effect will happens to this player
 */
/////////////////////////////////
/////////////////////////////////

- (void)addEnemyInScreen{
    int x = boardOffset + arc4random()%1024;
    CGPoint center = CGPointMake(x, 600);
    GameModel *model = [[GameModel alloc] initWithType:GameModelEnemy
                                          center:center
                                          size:(CGSizeMake(HORSEWIDTH, HORSEHEIGHT))
                        ];
    RectGameObject *enemy = [[GameEnemy alloc] initWithModel:model];
    UIView *view = [[UIView alloc] init];
    view = [FrameConstructor horseFrames];
    view.frame = CGRectMake(0, 0, model.size.width, model.size.height);
    view.center = model.center;
    enemy.view = view;
    
    [game addGameObjectToForeground:enemy];
    [enemy startAnimation];
}

- (void)upsideDown{
    self.board.transform = CGAffineTransformScale(self.board.transform, TRANSFORM_RATIO_X, TRANSFORM_RATIO_Y);
    [self performSelector:@selector(recoverUpsidedownScreen:) withObject:self.board afterDelay:2];
}

/**EFFECT:
 * User cannot paint lines for several seconds
 */
- (void)noMana{
    pan.enabled = NO;
    buttonPan.enabled = NO;
    self.switchButton.backgroundColor = [UIColor colorWithPatternImage:greyButton];
    [self performSelector:@selector(recoverMana) withObject:nil afterDelay:NO_INK_DELAY_TIME];
}

- (void)blinkOneSecond{
    self.BlinkLayer.hidden = NO;
    [self performSelector:@selector(hideBlinkLayer:) withObject:self.BlinkLayer afterDelay:BLINK_DELAY];
}

/**EFFECT:
 * Runner cannot run for several seconds
 */
- (void)stuckRunner{
    NSInteger speed = runner.speed;
    runner.speed = 0;
    [self performSelector:@selector(recoverSpeed:) withObject:[NSNumber numberWithInt:speed] afterDelay:STUCK_RUNNER_DELAY];
}

/////////////////////////////////
/////////////////////////////////



- (void)upsideDownMultiScreen{
    self.multiplayerView.transform = CGAffineTransformScale(self.multiplayerView.transform, TRANSFORM_RATIO_X, TRANSFORM_RATIO_Y);
    [self performSelector:@selector(recoverUpsidedownScreen:) withObject:self.multiplayerView afterDelay:UPSIDEDOWN_DELAY_TIME];
}

- (void)recoverUpsidedownScreen:(UIView*)view{
    view.transform = CGAffineTransformScale(view.transform, TRANSFORM_RATIO_X, TRANSFORM_RATIO_Y);
}

- (void)recoverMana{
    pan.enabled = YES;
    buttonPan.enabled = YES;
    UIImage *background = (game.currentInkType == RED_INK)?greenButton:redButton;
    self.switchButton.backgroundColor = [UIColor colorWithPatternImage:background];
}

- (void)recoverSpeed:(NSNumber*)speed{
    runner.speed = -[speed intValue];
}

- (void)blinkMultiScreen{
    self.multiBlinkLayer.hidden = NO;
    [self performSelector:@selector(hideBlinkLayer:) withObject:self.multiBlinkLayer afterDelay:BLINK_DELAY];
}

- (void)hideBlinkLayer:(UIView*)view{
    view.hidden = YES;
}

- (IBAction)pressSwitchButton:(id)sender {
    UIImage *background = (game.currentInkType == RED_INK)?greenButton:redButton;
    game.currentInkType = (game.currentInkType == RED_INK)?GREEN_INK:RED_INK;
    [self addTickView];
    self.switchButton.backgroundColor = [UIColor colorWithPatternImage:background];
}

- (void)addGameView:(UIView *)view {
    [self.board addSubview:view];
}

- (void)didIncreaseInkPoints {
    [getInkplayer play];
}

- (void)didSendGift {
    [triggerPlayer play];
    [self sendGiftPacket];
}

- (void)didUseUpInk {
    [warnningPlayer play];
    [self endDrawPath];
}

- (int)getCurrentOffset{
    return boardOffset;
}

- (NSMutableArray*)getForegroundObjects{
    return game.foregroundObjects;
}

- (NSMutableArray*)getPaths{
    return game.paths;
}

- (UIView*)getCanvas{
    return self.multiplayerView;
}

- (GameLevel*)getLevel{
    return level;
}

- (void)cleanUp {
    [redInkView removeFromSuperview];
    [greenInkView removeFromSuperview];
    [redInkStand removeFromSuperview];
    [greenInkStand removeFromSuperview];
    [self.board removeGestureRecognizer:pan];
    [self.switchButton removeGestureRecognizer:buttonPan];
    [game cleanUp];
}

@end
