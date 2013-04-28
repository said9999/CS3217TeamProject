//
//  GameQuestionMark.m
//  dsrunner
//
//  Created by sai on 4/17/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameQuestionMark.h"

@interface GameQuestionMark ()

@end

@implementation GameQuestionMark

- (id)initWithModel:(GameModel *)m{
    self = [super initWithModel:m];
    if (self) {
        return self;
    }
    NSLog(@"cannot init gameobjectqustionmark!");
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
