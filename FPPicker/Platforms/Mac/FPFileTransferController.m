//
//  FPFileTransferWindowController.m
//  FPPicker
//
//  Created by Ruben on 10/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileTransferController.h"
#import "FPUtils.h"
#import "FPInternalHeaders.h"
#import "FPBaseSourceController.h"

@interface FPFileTransferController ()

@property (nonatomic, assign) NSModalSession modalSession;
@property (readwrite) NSOperationQueue *operationQueue;

@end

@implementation FPFileTransferController

#pragma mark - Accessors

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [NSOperationQueue new];
    }

    return _operationQueue;
}

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPFileTransferController"];
    }

    return self;
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                                owner:(id)owner
{
    NSBundle *bundle;

    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"FPPickerMac"
                                               withExtension:@"bundle"];

    if (bundleURL)
    {
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    else
    {
        bundle = [NSBundle bundleForClass:self.class];
    }

    NSURL *nibURL = [bundle URLForResource:windowNibName
                             withExtension:@"nib"];

    self = [self initWithWindowNibPath:nibURL.path
                                 owner:owner];

    return self;
}

- (void)awakeFromNib
{
    [self.progressIndicator setIndeterminate:YES];
}

#pragma mark - NSWindowDelegate Methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
}

#pragma mark - Public Methods

- (void)process
{
    self.operationQueue.suspended = NO;
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];

    self.progressIndicator.minValue = 0.0;
    self.progressIndicator.maxValue = 1.0;
    self.progressIndicator.doubleValue = 0.0;

    [self.progressIndicator startAnimation:self];

    // NOTE: Subclasses should call [super process] so the window is shown before processing
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    self.operationQueue.suspended = YES;
    [self.operationQueue cancelAllOperations];

    [self.progressIndicator stopAnimation:self];
    [self.window close];

    [self.delegate FPFileTransferControllerDidCancel:self];
}

@end
