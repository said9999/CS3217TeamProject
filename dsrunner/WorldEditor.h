//
//  WorldEditor.h
//  dsrunner
//
//  Created by Cui Wei on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldEditorObjectsChangedProtocol.h"
//OVERVIEW: this class is the ViewController of world editor, which allows user to design
//          their own levels.

@interface WorldEditor : UIViewController<WorldEditorObjectsChangedProtocol, UIAlertViewDelegate>

@end
