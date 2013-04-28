//
//  LineView.m
//  PhysicsEngine
//
//  Created by Light on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Constants.h"
#import "PathView.h"

@interface PathView () {
    BOOL changed;
}

@property NSArray *points;

@end

void DrawPathPatternCallback(void *info, CGContextRef cgContext) {
    // EFFECTS: draw path using the given image as pattern
    CGContextDrawImage(cgContext, CGRectMake(PATTERN_ORIGIN_X, PATTERN_ORIGIN_Y, PATTERN_WIDTH, PATTERN_HEIGHT),
                       (CGImageRef)info);
}

// OVERVIEW: this class implements a view that renders a path
@implementation PathView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
        self.points = [NSMutableArray array];
        self.inkType = RED_INK;
        self.thickness = PATH_THICKNESS;
        changed = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (self.points.count < 2)
        return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //set patterns for the line
    const CGRect patternBounds = CGRectMake(0, 0, PATTERN_WIDTH, PATTERN_HEIGHT);
    CGPatternCallbacks patternCallbacks = {0, DrawPathPatternCallback, NULL};

    CGAffineTransform patternTransform = CGAffineTransformIdentity;
    NSString *patternImageName = self.inkType == GameModelBlockPath ? RED_BRUSH_IMAGE : GREEN_BRUSH_IMAGE;
        UIImage *patternImage = [UIImage imageNamed: patternImageName];
    CGPatternRef strokePattern = CGPatternCreate(patternImage.CGImage,
                                                 patternBounds,
                                                 patternTransform,
                                                 PATTERN_WIDTH, // horizontal spacing
                                                 PATTERN_HEIGHT,// vertical spacing
                                                 kCGPatternTilingNoDistortion,
                                                 true,
                                                 &patternCallbacks);
    
    CGFloat color1[] = {R, G, B, ALPHA};
    
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetStrokeColorSpace(context, patternSpace);
    CGContextSetStrokePattern(context, strokePattern, color1);
    CGContextSetShadow(context, CGSizeMake(SHADOW_X_OFFSET, SHADOW_Y_OFFSET), SHADOW_WIDTH);
    
    //set other properties for the line
    CGContextSetLineWidth(context, self.thickness);
    
    
    //start drawing
    CGPoint firstPoint = [self.points[0] CGPointValue];
    CGPoint offset = self.frame.origin;
    
    CGContextMoveToPoint(context, firstPoint.x - offset.x, firstPoint.y - offset.y);
    for (int i = 1; i < self.points.count; i++) {
        CGPoint point = [self.points[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x - offset.x, point.y - offset.y);
    }
    CGContextSetLineCap(context, kCGLineCapRound);//set style for endpoints
    //Draw it
    CGContextStrokePath(context);
}

- (void)addPoint:(CGPoint)pt {
    // EFFECTS: add a point to the path
    
    NSValue *v = [NSValue valueWithCGPoint:pt];
    [(NSMutableArray *)self.points addObject:v];
    changed = YES;
}

- (void)setNeedsDisplay {
    if (changed) {
        [super setNeedsDisplay];
        changed = NO;
    }
}

@end
