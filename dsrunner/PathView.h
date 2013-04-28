//
//  LineView.h
//  PhysicsEngine
//
//  Created by Light on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathView : UIView
// OVERVIEW: this class implements a view that renders a path

@property (readonly) NSArray *points;
@property int inkType;
@property int thickness;

- (void)addPoint:(CGPoint)pt;
// EFFECTS: add a point to the path

@end
