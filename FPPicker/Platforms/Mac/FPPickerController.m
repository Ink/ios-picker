//
//  FPPickerController.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPPrivateConfig.h"
#import "FPRemoteSourceController.h"
#import "FPSourceListController.h"
#import "FPSource.h"

@interface FPPickerController () <FPSourceListControllerDelegate,
                                  NSSplitViewDelegate>

@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPPickerController

#pragma mark - Accessors

- (NSWindow *)window
{
    if (!_window)
    {
        _window = self.view.window;
    }

    return _window;
}

#pragma mark - Other Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];

        self = [[self.class alloc] initWithNibName:@"FPPickerController"
                                            bundle:frameworkBundle];
    }

    return self;
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
}

#pragma mark - Actions

- (IBAction)openFiles:(id)sender
{
    // TODO: Open the files

    [self.window close];
}

- (IBAction)close:(id)sender
{
    [self.window close];
}

#pragma mark - FPSourceListControllerDelegate Methods

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPSource *)source
{
    self.remoteSourceController.source = source;

    [self.remoteSourceController fpLoadContentAtPath];
}

#pragma mark - NSWindowDelegate Methods

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp endModalSession:self.modalSession];
}

#pragma mark - NSSplitViewDelegate Methods

- (BOOL)           splitView:(NSSplitView *)splitView
    shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (BOOL)     splitView:(NSSplitView *)splitView
    canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMinCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 150)
    {
        proposedMinimumPosition = 150;
    }

    return proposedMinimumPosition;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition > 225)
    {
        proposedMinimumPosition = 225;
    }

    return proposedMinimumPosition;
}

@end
