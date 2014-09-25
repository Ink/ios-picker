//
//  FPPickerController.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPInternalHeaders.h"
#import "FPRemoteSourceController.h"
#import "FPSourceListController.h"
#import "FPSourceViewController.h"

@interface FPPickerController () <NSSplitViewDelegate,
                                  NSWindowDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;
@property (nonatomic, weak) IBOutlet FPSourceViewController *sourceViewController;
@property (nonatomic, weak) IBOutlet FPSourceListController *sourceListController;

@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPPickerController

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.fpLogo.image = [[FPUtils frameworkBundle] imageForResource:@"logo_small"];
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPPickerController"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(browserSelectionDidChange:)
                                                     name:FPBrowserSelectionDidChangeNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
}

#pragma mark - Notifications

- (void)browserSelectionDidChange:(NSNotification *)sender
{
    NSUInteger selectionCount = [sender.object unsignedIntegerValue];
    NSString *selectionString;

    switch (selectionCount)
    {
        case 0:
            selectionString = @"No items selected";

            break;
        case 1:
            selectionString = [NSString stringWithFormat:@"%lu item selected", (unsigned long)selectionCount];

            break;
        default:
            selectionString = [NSString stringWithFormat:@"%lu items selected", (unsigned long)selectionCount];

            break;
    }

    self.currentSelectionTextField.stringValue = selectionString;
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

#pragma mark - NSWindowDelegate Methods

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [self.sourceListController loadAndExpandSourceListIfRequired];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
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
