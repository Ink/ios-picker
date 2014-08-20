//
//  FPBorderView.m
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPBorderView.h"

@implementation FPBorderView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (NSEqualRects(dirtyRect, self.bounds))
    {
        // Drawing code here.

        NSColor *color = [NSColor lightGrayColor];
        NSColor *shadowColor = [[NSColor whiteColor] colorWithAlphaComponent:0.33];

        [color setStroke];

        NSShadow *shadow = [NSShadow new];

        [shadow setShadowColor:shadowColor];
        [shadow setShadowOffset:NSMakeSize(0.1, -1.1)];
        [shadow setShadowBlurRadius:0];
        [shadow set];

        NSBezierPath *bezierPath = [NSBezierPath bezierPath];

        CGPoint topLPoint = NSMakePoint(NSMinX(dirtyRect), NSMaxY(dirtyRect));
        CGPoint topRPoint = NSMakePoint(NSMaxX(dirtyRect), topLPoint.y);

        [bezierPath moveToPoint:topLPoint];
        [bezierPath lineToPoint:topRPoint];

        [bezierPath setLineWidth:2.0];
        [bezierPath stroke];
    }
}

@end
