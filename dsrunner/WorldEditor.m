//
//  WorldEditor.m
//  dsrunner
//
//  Created by Cui Wei on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "WorldEditor.h"
#import "WorldEditorObjects.h"
#import "WorldEditorGameObjects.h"
#import "Constants.h"
#import "CustomisedFileLoader.h"
#define REPLACE_LEVEL @"Replace Level"
#define REPLACE_LEVEL_CONFIRM @"Replace it"
#define REPLACE_LEVEL_MESSAGE @"Level name already exsits, replace it?"
//OVERVIEW: this class is the ViewController of world editor, which allows user to design
//          their own levels.
@interface WorldEditor ()

- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *addNewFrame;
@property (weak, nonatomic) IBOutlet UIView *palette;
@property (weak, nonatomic) IBOutlet UIScrollView *gameArea;
@property BOOL canLeaveSafely;
@property NSMutableString *level;
@property NSArray *customisedLevels;
@property NSString *filePath;
@end

@implementation WorldEditor


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.addNewFrame.transform = CGAffineTransformRotate(self.gameArea.transform, M_PI/2);
    self.level = [[NSMutableString alloc] init];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.addNewFrame addSubview:refreshControl];
    self.addNewFrame.userInteractionEnabled = YES;
    self.addNewFrame.scrollEnabled = YES;
    [self.addNewFrame setContentSize:makePaletteSize];
    
    self.gameArea.userInteractionEnabled = YES;
    self.gameArea.scrollEnabled = YES;
    [self.gameArea setContentSize:makeGameAreaSize];
    
    self.palette.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.palette.opaque = NO;
    self.canLeaveSafely =YES;
    [self setUpObject:GROUND_NAME];
    [self setUpObject:ENEMY_NAME];
    [self setUpObject:DESTINATION_NAME];
    self.customisedLevels = [CustomisedFileLoader getAllFilesUnderGameDirectory];
	
}

-(void)extendLevelString:(NSString*)s {
    //EFFECTS: append new gameObjects to level string
    
    [self.level appendString:s];
}

-(void)setUpLevelString {
    //EFFECTS:set up the basic structure of a level, including the dummy objects
    self.level = [[NSMutableString alloc] init];
    [self extendLevelString:[NSString stringWithFormat:LEVEL_START_XML_FORMAT,(int)self.gameArea.contentSize.width,DEFAULT_INK_AMOUNT,DEFAULT_RUNNER_SPEED,DEFAULT_RUNNER_X,DEFAULT_RUNNER_Y]];
    [self extendLevelString:DUMMY_DESTINATION];
    [self extendLevelString:DUMMY_DESTINATION];
    [self extendLevelString:DUMMY_ENEMY];
    [self extendLevelString:DUMMY_ENEMY];
    [self extendLevelString:DUMMY_GROUND];
    [self extendLevelString:DUMMY_GROUND];
    [self extendLevelString:[NSString stringWithFormat:GROUND_XML_FORMAT,10, 2000,-5,1000]];
}

-(void)setUpObject:(NSString*)type {
    //EFFECTS: add gameObjects to world with givin type.
    if([type isEqualToString:GROUND_NAME]){
        WorldEditorGameObjects *ground = [[WorldEditorGameObjects alloc] initWithType:GROUND_NAME];
        [self addChildViewController:ground];
        ground.myDelegate = self;
        ground.view.frame = CGRectMake(GROUND_PALETTE_POSITION_X, GROUND_PALETTE_POSITION_Y, ground.widthInPalette, ground.heightInPalette);
        [self.palette addSubview:ground.view];
        [self addGestureRecognizer:ground];
    } else if([type isEqualToString:ENEMY_NAME]){
        WorldEditorGameObjects *enemy = [[WorldEditorGameObjects alloc] initWithType:ENEMY_NAME];
        [self addChildViewController:enemy];
        enemy.myDelegate = self;
        enemy.view.frame = CGRectMake(ENEMY_PALETTE_POSITION_X, ENEMY_PALETTE_POSITION_Y, enemy.widthInPalette, enemy.heightInPalette);
        [self.palette addSubview:enemy.view];
        [self addGestureRecognizer:enemy];
    } else if([type isEqualToString:DESTINATION_NAME]){
        WorldEditorGameObjects *destination = [[WorldEditorGameObjects alloc] initWithType:DESTINATION_NAME];
        [self addChildViewController:destination];
        destination.myDelegate = self;
        destination.view.frame = CGRectMake(ENEMY_PALETTE_POSITION_X+160, ENEMY_PALETTE_POSITION_Y-10, destination.widthInPalette, destination.heightInPalette);
        [self.palette addSubview:destination.view];
        [self addGestureRecognizer:destination];
    }
    
}
-(void)handleRefresh:(UIRefreshControl*)refresh{
    //EFFECTS: lengthen the level
    [self.gameArea setContentSize:CGSizeMake(self.gameArea.contentSize.width+1000 , self.gameArea.contentSize.height)];
    [refresh endRefreshing];
}

- (void)viewDidUnload {
    [self setPalette:nil];
    [self setGameArea:nil];
    [super viewDidUnload];
}


#pragma World Editor Objects Changed Protocol

-(void)addGestureRecognizer:(UIViewController*)theViewController{
    //EFFECTS: add gesture to VCs
    
    WorldEditorObjects *objectViewController = (WorldEditorObjects*)theViewController;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:objectViewController action:@selector(translate:)];
    
    [objectViewController.view addGestureRecognizer:pan];
    objectViewController.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:objectViewController action:@selector(doubleTapToRemove)];
    doubleTap.numberOfTapsRequired = 2;
    [objectViewController.view addGestureRecognizer:doubleTap];
    if ([objectViewController.type isEqualToString:GROUND_NAME]) {
        UIPinchGestureRecognizer *zoom = [[UIPinchGestureRecognizer alloc]initWithTarget:objectViewController action:@selector(resizeView:)];
        [objectViewController.view addGestureRecognizer:zoom];
    }
    
}
-(void)levelChanged{
    self.canLeaveSafely = NO;
}

-(BOOL)shouldAddToGameArea:(UIView*)view{
    
    if(view.superview == self.palette && (view.center.y - view.frame.size.height/2 > self.palette.frame.size.height))
        return YES;
    else
        return NO;
}

-(void)objectsInWorldEditorDidChange{
    self.canLeaveSafely = NO;
    
}

-(void)addToGameAreaWithView:(UIView*)theView{
    
    theView.frame = CGRectMake(theView.frame.origin.x + self.gameArea.contentOffset.x,
                               theView.frame.origin.y - self.palette.frame.size.height,
                               theView.frame.size.width,
                               theView.frame.size.height);
    
    [self.gameArea addSubview:theView];
    
}

-(void)disableGameArea{
    self.gameArea.userInteractionEnabled = NO;
}

-(void)enableGameArea{
    self.gameArea.userInteractionEnabled = YES;
    
}

-(BOOL)isInPalette:(UIView*)view{
    return view.superview == self.palette;
}

-(void)killViewController:(UIViewController*)gameObjectVC{
    //EFFECTS:remove the VC.
    
    [gameObjectVC.view removeFromSuperview];
    [gameObjectVC removeFromParentViewController];
    
}
-(void)createNewVC:(UIViewController*)gameObjectVC{
    //EFFECTS:Create VCs of gameObjects and set them in palette
    WorldEditorGameObjects *obj = (WorldEditorGameObjects*)gameObjectVC;
    
    if([obj.type isEqualToString:GROUND_NAME]){
        
        [self setUpObject:GROUND_NAME];
        
    } else if ([obj.type isEqualToString:ENEMY_NAME]){
        
        [self setUpObject:ENEMY_NAME];
    }
}

- (IBAction)homeButtonPressed:(id)sender {
    //EFFECTS: return home if the level is saved, otherwise pop-up a alert.
    if(self.canLeaveSafely)
        [self goBackHome];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CHANGES_NOT_SAVED
                                                        message:LEAVE_WITHOUT_SAVING
                                                       delegate:self
                                              cancelButtonTitle:CANCEL_BUTTON
                                              otherButtonTitles:CANCEL_SAVE, nil];
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //EFFECTS: define behaviours of different alertView.
    
    if([alertView.title isEqualToString:CHANGES_NOT_SAVED]){
        if(buttonIndex == 1)
            [self goBackHome];
    }
    
    if([alertView.title isEqualToString:SAVE_TITLE]){
        UITextField* textField = [alertView textFieldAtIndex:0];
        
        if(textField.text != nil && ![textField.text isEqual:@"" ] && buttonIndex == 1){
            NSMutableString *levelName = [NSString stringWithFormat:LEVEL_FORMAT,textField.text];
            [self saveMyBuilding:levelName];
            self.canLeaveSafely = true;
        }
        
        else if(buttonIndex == 1){
            
            UIAlertView* savingAborted = [[UIAlertView alloc] initWithTitle:SAVE_ABORT
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:CONFIRM_BUTTON
                                                          otherButtonTitles:nil];
            [savingAborted show];
        }
        
    }
    
    if([alertView.title isEqualToString:REPLACE_LEVEL]){
        if(buttonIndex == 1){//replace level
            [self saveStringToFile];
        }
    }
}

-(void)goBackHome{
    //EFFECTS: return to home screen.
    [self performSegueWithIdentifier:SEGUE_FROM_WE_TO_MP sender:nil];
    
}

- (IBAction)saveButtonPressed:(id)sender {
    //EFFECTS: Save the level
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:SAVE_TITLE
                                                     message:SAVE_MESSAGE
                                                    delegate:self
                                           cancelButtonTitle:CANCEL_BUTTON
                                           otherButtonTitles:CONFIRM_BUTTON, nil];
    
    dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [dialog show];
}

-(Boolean)saveStringToFile{
    NSError *error;
    NSLog(@"%@",self.level);
    BOOL status = [self.level writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    while(!status)
        status = [self.level writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    return status;
    
}

-(Boolean)saveMyBuilding:(NSString*) levelName{
    //EFFECTS: save the level using the attributes of the views on gameArea.
    
    [self setUpLevelString];
    for (UIView *view in self.gameArea.subviews){
        switch (view.tag) {
            case GameModelEnemy:
                [self extendLevelString:[NSString stringWithFormat:ENEMY_XML_FORMAT,(int)view.center.x,GAME_AREA_HEIGHT-(int)view.center.y]];
                break;
            case GameModelGround:
                [self extendLevelString:[NSString stringWithFormat:GROUND_XML_FORMAT,(int)view.frame.size.width,
                                         (int)view.frame.size.height,(int)view.center.x,GAME_AREA_HEIGHT-(int)view.center.y]];
                break;
            case GameModelDestination:
                [self extendLevelString:[NSString stringWithFormat:DESTINATION_XML_FORMAT,(int)view.frame.size.width,
                                         (int)view.frame.size.height,(int)view.center.x,GAME_AREA_HEIGHT-(int)view.center.y]];
                break;
                
            default:
                break;
        }
    }
    [self extendLevelString:LEVEL_END_XML_FORMAT];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.filePath = [documentsDirectory stringByAppendingPathComponent:levelName];
    for (NSString *level in self.customisedLevels){
        if ([level isEqualToString:levelName]){
            UIAlertView *replaceLevel = [[UIAlertView alloc] initWithTitle:REPLACE_LEVEL
                                                                   message:REPLACE_LEVEL_MESSAGE
                                                                  delegate:self
                                                         cancelButtonTitle:CANCEL_BUTTON
                                                         otherButtonTitles:REPLACE_LEVEL_CONFIRM, nil];
            [replaceLevel show];
        }
        
    }
    
    return [self saveStringToFile];
    
}

@end
