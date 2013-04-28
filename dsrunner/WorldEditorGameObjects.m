//
//  WorldEditorGameGround.m
//  dsrunner
//
//  Created by Cui Wei on 4/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "WorldEditorGameObjects.h"

@interface WorldEditorGameObjects ()

@end

@implementation WorldEditorGameObjects

-(id)initWithType:(NSString *)type{
//EFFECTS: return a new WorldEditorGameObjects with give type string.

    if(self = [super init]){

        self.type = type;
        UIImage *groundImg;
        if([self.type isEqualToString:GROUND_NAME]){
            groundImg = [UIImage imageNamed:BRICK_GROUND_IMAGE];
            self.imgWidth = groundImg.size.width;
            self.imgHeight = groundImg.size.height;
        }

        else if([self.type isEqualToString:ENEMY_NAME]){
            groundImg = [UIImage imageNamed:ENEMY_IMAGE];
            self.imgWidth = groundImg.size.width * 0.6;
            self.imgHeight = groundImg.size.height * 0.6;
        }

        else if([self.type isEqualToString:DESTINATION_NAME]){
            groundImg = [UIImage imageNamed:DESTINATION_IMAGE];
            self.imgWidth = groundImg.size.width * 0.45;
            self.imgHeight = groundImg.size.height * 0.45;
        }

        self.widthInPalette = 0.8 * self.imgWidth;
        self.heightInPalette = 0.8 * self.imgHeight;
        [self setBackground];

    }
    return self;

}


-(void)setBackground{
    //EFFECTS: set up the gameObjects' background.
    UIImage* groundImg;

    if([self.type isEqualToString:GROUND_NAME]){

        groundImg = [UIImage imageNamed:SMALL_BRICK_IMAGE];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithPatternImage:groundImg];
        self.view = view;
        self.view.tag = GameModelGround;

    } else if([self.type isEqualToString:ENEMY_NAME]){

        groundImg = [UIImage imageNamed:ENEMY_IMAGE];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:groundImg];
        self.view = imgView;
        self.view.tag = GameModelEnemy;

    } else if([self.type isEqualToString:DESTINATION_NAME]){

        groundImg = [UIImage imageNamed:DESTINATION_IMAGE];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:groundImg];
        self.view = imgView;
        self.view.tag = GameModelDestination;

    }


    [self.myDelegate addGestureRecognizer:self];

}





@end
