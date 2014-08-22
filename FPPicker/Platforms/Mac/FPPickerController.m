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
#import "FPNavigationController.h"

@interface FPPickerController () <FPSourceListControllerDelegate,
                                  NSSplitViewDelegate,
                                  NSWindowDelegate>

@property (nonatomic, weak) IBOutlet FPRemoteSourceController *remoteSourceController;
@property (nonatomic, weak) IBOutlet FPSourceListController *sourceListController;
@property (nonatomic, weak) IBOutlet FPNavigationController *navigationController;

@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPPickerController

#pragma mark - Other Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPPickerController"];
    }

    return self;
}

- (void)open
{
    [self.window orderOut:self];

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

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [self.sourceListController loadAndExpandSourceListIfRequired];
}

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
