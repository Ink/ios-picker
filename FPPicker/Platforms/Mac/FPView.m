//
//  FPView.m
//  FPPicker
//
//  Created by Ruben Nine on 21/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPView.h"

@implementation FPView

#pragma mark - Accessors

- (NSColor *)backgroundColor
{
    if (!_backgroundColor)
    {
        _backgroundColor = [NSColor controlColor];
    }

    return _backgroundColor;
}

#pragma mark - Public Methods

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    // Drawing code here.

    [self.backgroundColor setFill];

    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRect:self.bounds];

    [bezierPath fill];
}

@end
