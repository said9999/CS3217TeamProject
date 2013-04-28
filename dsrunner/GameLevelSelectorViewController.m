//
//  GameLevelSelectorViewController.m
//  dsrunner
//
//  Created by Cui Wei on 4/7/13.
//  @Author: Chen Zeyu
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameLevelSelectorViewController.h"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"
#import "Constants.h"
#import "CustomisedFileLoader.h"
#define LEVEL_BACKGROUND @"levelButtonBackground.png"
#define SEGUE_FROM_LEVEL_SELETOR_TO_SINGLE_PLAYER_MODE @"GAME_LEVEL_SELECTOR_TO_SINGLE_PLAYER_MODE"
#define SHEET_TITLE @"Options"
#define SHEET_DELETE_MESSAGE @"Delete"
#define SHEET_X_OFFSET 80
#define SHEET_WIDTH 200
#define SHEET_HEIGHT 400

@interface GameLevelSelectorViewController ()

@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIScrollView *selectView;
@property NSArray *userDesignedLevels;
@property UIActionSheet *removeLevelSheet;
@property NSString *levelToDelete;
@end

@implementation GameLevelSelectorViewController


- (void)viewDidLoad
{
    self.player = [AudioPlayer playAudio:BACKGROUND_MUSIC audioFormat:WAV_FORMAT];
    self.selectView.userInteractionEnabled = YES;
    self.selectView.scrollEnabled = YES;
    [self setUpUerDesignedLevels];
    self.player.numberOfLoops = -1;
    [self.player play];
}

-(void)setUpUerDesignedLevels{
    //EFFECTS: set the ContentSize of selectView according to the number of user-designed levels
    //         adds button to selectView
    self.userDesignedLevels = [CustomisedFileLoader getAllFilesUnderGameDirectory];
    NSInteger pages = (int)ceilf([self.userDesignedLevels count]/6.0) + 1;
    [self.selectView setContentSize:CGSizeMake(pages * SELECT_VIEW_WIDTH, SELECT_VIEW_HEIGHT)];
    [self setUpButtons];
}

-(void)removeLevel:(NSString *)levelName{
    //EFFECTS: remove the file
    NSString *levelPath = [CustomisedFileLoader getLevelPath:levelName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:levelPath]){
        NSError *err = nil;
        if (![fileManager removeItemAtPath:levelPath error:&err])
        {
            NSLog(@"Error removing file: %@", err);
        }
    }
}
-(void)setUpButtons{
    //EFFECTS: create buttons according to the user-designed levels on the fly.
    CGRect nextButtonPosition = DEFAULT_BUTTON_POSITION;
    NSInteger count = 0;
    for (NSString *level in self.userDesignedLevels){
        UILongPressGestureRecognizer *longPress = [self getLongPressRecongnizer];
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button addGestureRecognizer:longPress];
        NSString *title = [self extractLevelNumber:level separater:USER_LEVEL_SEPARATOR];
        button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed: LEVEL_BACKGROUND]];
        [button setTitle: title forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:30];
        [button setFrame: nextButtonPosition];
        [self.selectView addSubview:button];
        button.tag = USER_LEVEL_BUTTON_TAG;
        [button addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
        nextButtonPosition = [self getNextButtonPostion:nextButtonPosition counter: ++count];
    }
}

-(UILongPressGestureRecognizer*)getLongPressRecongnizer{
    //EFFECTS: return a LongPressReconginicer with action
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(showLevelOptions:)];
    longPressRecognizer.minimumPressDuration = 0.8;
    longPressRecognizer.numberOfTouchesRequired = 1;
    return longPressRecognizer;
}

-(void)setUpActionSheet{
    self.removeLevelSheet = [[UIActionSheet alloc] initWithTitle:SHEET_TITLE
                                                        delegate:self
                                               cancelButtonTitle:CANCEL_BUTTON
                                          destructiveButtonTitle:SHEET_DELETE_MESSAGE
                                               otherButtonTitles:nil];
}

-(IBAction)showLevelOptions:(UIGestureRecognizer *)sender{
    //EFFECTS: handler of the longPressRecongnizer
    if(!self.removeLevelSheet){
        self.levelToDelete = [NSString stringWithFormat:LEVEL_FORMAT,((UIButton*)sender.view).titleLabel.text];
        [self setUpActionSheet];
        CGPoint p = [sender locationInView:self.selectView];
        [self.removeLevelSheet showFromRect:CGRectMake(p.x - SHEET_X_OFFSET, p.y, SHEET_WIDTH, SHEET_HEIGHT) inView:self.selectView animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self removeLevel:self.levelToDelete];
        [self clear];
    }
    self.removeLevelSheet = nil;
    
}

-(CGRect)getNextButtonPostion:(CGRect) nextButtonPosition counter: (NSInteger) counter{
    //EFFECTS:return the next button's postion of user designed level.
    //        6 levels in one screen
    if(counter % 3 == 0 && counter % 6 == 0) {
        //at last button of one page
        nextButtonPosition = CGRectMake(nextButtonPosition.origin.x + INCREMENT_PAGE, nextButtonPosition.origin.y - INCREMENT, BUTTON_LENTH, BUTTON_LENTH);
        
    } else if(counter % 3 == 0 && counter % 6 != 0){
        //at 3rd button of one page
        nextButtonPosition = CGRectMake(nextButtonPosition.origin.x - 2 * INCREMENT, nextButtonPosition.origin.y + INCREMENT, BUTTON_LENTH, BUTTON_LENTH);
        
    } else 
        nextButtonPosition = CGRectMake(nextButtonPosition.origin.x + INCREMENT, nextButtonPosition.origin.y , BUTTON_LENTH, BUTTON_LENTH);
    
    return nextButtonPosition;
}

-(NSString*)extractLevelNumber:(NSString*)levelName separater:(NSString*)sep{
    //EFFECTS: extract level name from button's text, and return the name as a NSString.
    if([levelName hasPrefix:USER_LEVEL_PREFIX])
        levelName = [levelName substringWithRange:NSMakeRange(0, [levelName length] - 4)];
    
    NSArray* components = [levelName componentsSeparatedByString:sep];
    return (NSString*)components[1];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [self.player stop];
    UIButton* mybutton = (UIButton*) sender;
    NSString *levelName;
    if(mybutton.tag == USER_LEVEL_BUTTON_TAG){
        levelName = [NSString stringWithFormat:LEVEL_FORMAT, mybutton.titleLabel.text];
    } else
        levelName = [NSString stringWithFormat:DEFAULT_LEVEL_FORMAT,
                     [self extractLevelNumber:mybutton.titleLabel.text separater:DEFAULT_LEVEL_SEPARATOR]];
    
    
    if ([segue.identifier isEqualToString:SEGUE_FROM_LEVEL_SELETOR_TO_SINGLE_PLAYER_MODE]) {
        
        
        
        [segue.destinationViewController performSelector:@selector(setSelectedGameLevel:) withObject:levelName];
    }
}

-(void)clear{
    self.levelToDelete = nil;
    self.userDesignedLevels = nil;
    self.removeLevelSheet = nil;
    [self.player stop];
    self.player = nil;
    for(UIView* view in [self.selectView subviews]){
        if(view.tag == USER_LEVEL_BUTTON_TAG)
            [view removeFromSuperview];
    }
    [self viewDidLoad];
}

- (IBAction)enterGame:(id)sender {
    
    [self performSegueWithIdentifier:SEGUE_FROM_LEVEL_SELETOR_TO_SINGLE_PLAYER_MODE sender:sender];
}

@end
