//
//  FPFileTransferWindowController.m
//  FPPicker
//
//  Created by Ruben on 10/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileTransferWindowController.h"
#import "FPUtils.h"
#import "FPInternalHeaders.h"
#import "FPBaseSourceController.h"
#import "FPProgressTracker.h"

@interface FPFileTransferWindowController ()

@property (nonatomic, strong) FPProgressTracker *progressTracker;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPFileTransferWindowController

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPFileTransferWindowController"];
    }

    return self;
}

- (void)awakeFromNib
{
    [self.progressIndicator setIndeterminate:YES];
}

#pragma mark - Accessors

- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [NSMutableArray array];
    }

    return _items;
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

- (void)enqueueItems:(NSArray *)items
{
    [self.items addObjectsFromArray:items];
}

- (void)process
{
    if (self.items.count == 0)
    {
        return;
    }

    if (!self.delegate)
    {
        [NSException raise:@"Delegate is missing"
                    format:@"FPFileTransferWindowController needs a delegate."];

        return;
    }

    if (!self.sourceController)
    {
        [NSException raise:@"Source controller is missing"
                    format:@"FPFileTransferWindowController needs a source controller."];

        return;
    }

    BOOL shouldDownload = [self.delegate FPFileTransferControllerShouldDownload:self];
    NSUInteger totalCount = self.items.count;
    NSMutableArray *results = [NSMutableArray array];

    __block NSUInteger itemsProcessed = 0;
    __block BOOL hasStarted = NO;

    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];

    self.descriptionTextField.stringValue = [NSString stringWithFormat:@"About to start downloading %ld file(s)", totalCount];

    self.progressIndicator.minValue = 0.0;
    self.progressIndicator.maxValue = 1.0;
    self.progressIndicator.doubleValue = 0.0;

    [self.progressIndicator startAnimation:self];

    self.progressTracker = [[FPProgressTracker alloc] initWithObjectCount:totalCount];

    dispatch_apply(totalCount,
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(size_t blockIdx) {
        void (^markProgress)() = ^void () {
            itemsProcessed++;

            [self.progressTracker setProgress:1.0
                                       forKey:@(blockIdx)];

            if (itemsProcessed >= totalCount)
            {
                [self.progressIndicator stopAnimation:self];
                [self.window close];

                if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(FPFileTransferController:didFinishDownloadingItems:)])
                {
                    [self.delegate FPFileTransferController:self
                                  didFinishDownloadingItems:[results copy]];
                }
            }
            else
            {
                self.descriptionTextField.stringValue = [NSString stringWithFormat:@"Downloading %ld of %ld file(s)", itemsProcessed + 1, totalCount];
            }
        };

        FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
            DLog(@"Got item %p", mediaInfo);

            [results addObject:mediaInfo];

            markProgress();
        };

        FPFetchObjectFailureBlock failureBlock = ^(NSError * error) {
            DLog(@"Error retrieving %@: %@", self.items[blockIdx], error);

            markProgress();
        };

        FPFetchObjectProgressBlock progressBlock = ^(float progress) {
            if (!hasStarted)
            {
                hasStarted = YES;

                self.descriptionTextField.stringValue = [NSString stringWithFormat:@"Downloading 1 of %ld file(s)", totalCount];

                [self.progressIndicator setIndeterminate:NO];
            }

            [self.progressTracker setProgress:progress
                                       forKey:@(blockIdx)];

            self.progressIndicator.doubleValue = [self.progressTracker calculateProgress];
        };

        [self.sourceController requestObjectMediaInfo:self.items[blockIdx]
                                       shouldDownload:shouldDownload
                                              success:successBlock
                                              failure:failureBlock
                                             progress:progressBlock];
    });
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.sourceController cancelAllOperations];

    DLog(@"User cancelled transfer.");
}

@end
