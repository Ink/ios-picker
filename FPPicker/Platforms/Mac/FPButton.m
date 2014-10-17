//
//  FPButton.m
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPButton.h"

@interface FPButton ()

@property (nonatomic, assign) NSInteger numberOfCaptures;
@property (nonatomic, strong) NSTrackingArea *mouseTrackingArea;
@property (nonatomic, strong) NSImage *originalImage;

@end

@implementation FPButton

#pragma mark - Tracking Area

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];

    if (self.mouseTrackingArea)
    {
        [self removeTrackingArea:self.mouseTrackingArea];
    }

    NSTrackingArea *mouseTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                                       owner:self
                                                                    userInfo:nil];

    [self addTrackingArea:self.mouseTrackingArea = mouseTrackingArea];
}

#pragma mark - Event Handling

- (void)viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    [self resetMouseCaptures];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    [self didCaptureMousePointer];
    [self updateRollOverImage];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    [self didReleaseMousePointer];
    [self updateRollOverImage];
}

- (void)updateRollOverImage
{
    if ([self shouldDisplayRollOver] &&
        [self isEnabled])
    {
        self.originalImage = self.image;
        self.image = self.rolloverImage;
    }
    else
    {
        self.image = self.originalImage;
    }
}

#pragma mark - Private Methods

- (void)didCaptureMousePointer
{
    self.numberOfCaptures++;
}

- (void)didReleaseMousePointer
{
    self.numberOfCaptures--;
}

- (BOOL)shouldDisplayRollOver
{
    return self.numberOfCaptures > 0;
}

- (void)resetMouseCaptures
{
    self.numberOfCaptures = 0;
}

@end
