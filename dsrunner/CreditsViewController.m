//
//  CreditsViewController.m
//  dsrunner
//
//  Created by Cui Wei on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CreditsViewController.h"
#import "Constants.h"


#define CREDITS_TEXT @"Instructor:\nDr. Sim Khe Chai\nAssistant Professor\nNational University of Singapore\n\nProgrammer:\nChen Zeyu\nCui Wei\nJiang YaoXuan\nYang ManSheng\n"
#define CREDITS_TIMER_INTERVAL 0.03
#define CREDITS_CONTENT_YCOORDINATE_DECREMENT 2

@interface CreditsViewController ()


@property NSTimer *mytimer;


@property (weak, nonatomic) IBOutlet UITextView *content;


@end

@implementation CreditsViewController


- (void)viewDidLoad
{
    
    self.content.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.content.opaque = NO;
    
    self.content.text = CREDITS_TEXT;
    
    self.mytimer = [NSTimer scheduledTimerWithTimeInterval:CREDITS_TIMER_INTERVAL
                                                        target:self
                                                      selector:@selector(scrollTextFieldUp)
                                                      userInfo:Nil
                                                       repeats:YES];
     
    
   	
}


-(void)scrollTextFieldUp{
//EFFECT: move up the text field up by 2 coordinate units
    self.content.center = CGPointMake(self.content.center.x, self.content.center.y-CREDITS_CONTENT_YCOORDINATE_DECREMENT);
}



- (void)viewDidUnload {
    [self setContent:nil];
    [super viewDidUnload];
}
@end
