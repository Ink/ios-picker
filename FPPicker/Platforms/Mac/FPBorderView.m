//
//  FPBorderView.m
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPBorderView.h"

@implementation FPBorderView

#pragma mark - Accessors

- (NSColor *)borderColor
{
    if (!_borderColor)
    {
        _borderColor = [NSColor lightGrayColor];
    }

    return _borderColor;
}

- (NSColor *)borderShadowColor
{
    if (!_borderShadowColor)
    {
        _borderShadowColor = [[NSColor whiteColor] colorWithAlphaComponent:0.33];
    }

    return _borderShadowColor;
}

#pragma mark - Public Methods

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (self.borderStyle != 0)
    {
        // Drawing code here.

        NSShadow *shadow = [NSShadow new];

        [shadow setShadowColor:self.borderShadowColor];
        [shadow setShadowBlurRadius:0];

        [self.borderColor setStroke];

        NSBezierPath *bezierPath = [NSBezierPath bezierPath];

        [bezierPath setLineWidth:2.0];

        if (self.borderStyle & FPBorderTop)
        {
            [shadow setShadowOffset:NSMakeSize(0.1, -1.1)];
            [shadow set];

            CGPoint topLPoint = NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds));
            CGPoint topRPoint = NSMakePoint(NSMaxX(self.bounds), topLPoint.y);

            [bezierPath moveToPoint:topLPoint];
            [bezierPath lineToPoint:topRPoint];
            [bezierPath stroke];
        }

        if (self.borderStyle & FPBorderBottom)
        {
            [shadow setShadowOffset:NSMakeSize(0.1, 1.1)];
            [shadow set];

            CGPoint bottomLPoint = NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds));
            CGPoint bottomRPoint = NSMakePoint(NSMaxX(self.bounds), bottomLPoint.y);

            [bezierPath removeAllPoints];
            [bezierPath moveToPoint:bottomLPoint];
            [bezierPath lineToPoint:bottomRPoint];
            [bezierPath stroke];
        }
    }
}

@end
