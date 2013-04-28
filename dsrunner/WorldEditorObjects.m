//
//  WorldEditorObjects.m
//  dsrunner
//
//  Created by Cui Wei on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "WorldEditorObjects.h"

@interface WorldEditorObjects ()

@property CGPoint lastTouchPositionIndexZero;
@property CGPoint lastTouchPositionIndexOne;

@end

@implementation WorldEditorObjects


- (void)translate:(UIPanGestureRecognizer*)gesture{
    //EFFECTS: translation handler.
    
    
    [self.myDelegate disableGameArea];
    
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    
    
    
    [gesture setTranslation:CGPointZero inView:gesture.view.superview];
    
    if(gesture.state == UIGestureRecognizerStateBegan && [self.myDelegate isInPalette:self.view]){
        [self.myDelegate createNewVC:self];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged && [self.myDelegate shouldAddToGameArea:gesture.view]) {
        
        [self.myDelegate addToGameAreaWithView:gesture.view];
        
    }
    
    
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        [self.myDelegate enableGameArea];
        
        if([self.myDelegate isInPalette:self.view]){
            [self.myDelegate killViewController:self];
            if([self.type isEqualToString:DESTINATION_NAME])
                [self.myDelegate setUpObject:DESTINATION_NAME];
        }
        
    }
    
    [self.myDelegate levelChanged];
    
    
}

-(void)doubleTapToRemove{
//EFFECTS: remove view from its superview
    if([self.myDelegate isInPalette:self.view])
        return;
    
    [self.myDelegate killViewController:self];
    [self.myDelegate levelChanged];
}


-(void)resizeView:(UIPinchGestureRecognizer*)gesture{
   //EFFECTS: resize the gameObjects in gameArea.
    
    if ([gesture state] == UIGestureRecognizerStateBegan){
        
        self.lastTouchPositionIndexZero = [gesture locationOfTouch:0 inView:gesture.view.superview];
        self.lastTouchPositionIndexOne  = [gesture locationOfTouch:1 inView:gesture.view.superview];
        if(self.lastTouchPositionIndexZero.x > self.lastTouchPositionIndexOne.x){
            CGPoint tmp = self.lastTouchPositionIndexZero;
            self.lastTouchPositionIndexZero = self.lastTouchPositionIndexOne;
            self.lastTouchPositionIndexOne = tmp;
        }
        
    }
    else if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged){
        if([gesture numberOfTouches] < 2) return;
        CGPoint currentTouchPositionIndexZero = [gesture locationOfTouch:0 inView:gesture.view.superview];
        CGPoint currentTouchPositionIndexOne  = [gesture locationOfTouch:1 inView:gesture.view.superview];
        if(currentTouchPositionIndexZero.x > currentTouchPositionIndexOne.x){
            CGPoint tmp = currentTouchPositionIndexZero;
            currentTouchPositionIndexZero = currentTouchPositionIndexOne;
            currentTouchPositionIndexOne = tmp;
        }
        
        BOOL needRevert = NO;
        if(currentTouchPositionIndexOne.y < currentTouchPositionIndexZero.y)
            needRevert = YES;
        
        CGPoint lastDistanceVector = [self CGPointDistanceBetweenFirstPoint:self.lastTouchPositionIndexZero secondPoint:self.lastTouchPositionIndexOne];
        CGPoint currentDistanceVector = [self CGPointDistanceBetweenFirstPoint:currentTouchPositionIndexZero secondPoint:currentTouchPositionIndexOne];
        
        CGFloat xChange =  currentDistanceVector.x - lastDistanceVector.x;
        CGFloat yChange =  currentDistanceVector.y - lastDistanceVector.y;
        if(needRevert) yChange = -yChange;
        CGFloat newWidth  = gesture.view.frame.size.width + xChange;
        CGFloat newHeight = gesture.view.frame.size.height + yChange;
        if(newWidth < self.widthInPalette || newHeight<self.heightInPalette){
            newWidth = gesture.view.frame.size.width;
            newHeight = gesture.view.frame.size.height;
        }
        
        
        gesture.view.frame = CGRectMake(gesture.view.center.x - newWidth/2,
                                        gesture.view.center.y - newHeight/2,
                                        newWidth,
                                        newHeight);
        
        [gesture setScale:1];
        
        self.lastTouchPositionIndexZero = currentTouchPositionIndexZero;
        self.lastTouchPositionIndexOne  = currentTouchPositionIndexOne;
        [self.myDelegate levelChanged];
    }
    
    
}

-(CGPoint)CGPointDistanceBetweenFirstPoint:(CGPoint)point1 secondPoint:(CGPoint)point2{
    return  CGPointMake(point2.x - point1.x, point2.y - point1.y);
}


@end
