//
//  worldEditorObjectsChangedProtocol.h
//  dsrunner
//
//  Created by Cui Wei on 4/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WorldEditorObjectsChangedProtocol <NSObject>

-(void)objectsInWorldEditorDidChange;
//EFFECTS: Set self.canLeaveSafely = NO; 
-(void)addToGameAreaWithView:(UIView*)theView;
//EFFECTS: Add the view to GameArea
-(void)disableGameArea;
//EFFECTS: Disable user interaction of gameArea;
-(void)enableGameArea;
//EFFECTS: Enable user interaction of gameArea;
-(BOOL)shouldAddToGameArea:(UIView*)view;
//EFFECTS: Determine if the view should be added to gameArea according to its current position.
-(BOOL)isInPalette:(UIView*)view;
//EFFECTS: Detect if the view is in Palette;
-(void)killViewController:(UIViewController*)gameObjectVC;
//EFFECTS: remove VC
-(void)createNewVC:(UIViewController*)gameObjectVC;
//EFFECTS: Create VCs and set them up in correct position
-(void)addGestureRecognizer:(UIViewController*)gameObjectVC;
//EFFECTS: Add gesture to VCs.
-(void)levelChanged;
//EFFECTS: set self.canLeaveSafely = NO;
-(void)setUpObject:(NSString*)type;
//EFFECTS: setup the objects in pallete.
@end
