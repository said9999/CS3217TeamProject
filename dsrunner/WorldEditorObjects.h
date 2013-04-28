//
//  WorldEditorObjects.h
//  dsrunner
//
//  Created by Cui Wei on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldEditorObjectsChangedProtocol.h"
#import "Constants.h"

@interface WorldEditorObjects : UIViewController

@property CGFloat imgWidth;
@property CGFloat imgHeight;
@property CGFloat widthInPalette;
@property CGFloat heightInPalette;
@property NSString *type;
@property (weak) id<WorldEditorObjectsChangedProtocol> myDelegate;

-(void)translate:(UIPanGestureRecognizer*)gesture;
//EFFECTS: Translate handler.
-(void)doubleTapToRemove;
//EFFECTS: Remove the view if it is double tapped.

@end
