//
//  FPFileDownloadController.m
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileDownloadController.h"
#import "FPUtils.h"
#import "FPInternalHeaders.h"
#import "FPBaseSourceController.h"
#import "FPProgressTracker.h"

@interface FPFileTransferController ()

@property (readonly, assign) BOOL wasProcessCancelled;

- (IBAction)cancel:(id)sender;

@end

@interface FPFileDownloadController ()

@property (readwrite, nonatomic, strong) NSArray *items;
@property (nonatomic, strong) FPProgressTracker *progressTracker;

@end

@implementation FPFileDownloadController

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];

    if (self)
    {
        self.shouldDownloadData = YES;
        self.items = items;
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Public Methods

- (void)process
{
    [super process];

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

    NSUInteger totalCount = self.items.count;
    NSMutableArray *results = [NSMutableArray array];

    __block NSUInteger itemsProcessed = 0;
    __block BOOL hasStarted = NO;

    self.descriptionTextField.stringValue = [NSString stringWithFormat:@"About to start downloading %ld file(s)", totalCount];

    [self.progressIndicator startAnimation:self];

    self.progressTracker = [[FPProgressTracker alloc] initWithObjectCount:totalCount];

    dispatch_apply(totalCount,
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(size_t blockIdx) {
        NSDictionary *item = self.items[blockIdx];

        void (^markProgress)() = ^void () {
            itemsProcessed++;

            [self.progressTracker setProgress:1.0
                                       forKey:@(blockIdx)];

            if (itemsProcessed >= totalCount)
            {
                [self.progressIndicator stopAnimation:self];
                [self.window close];

                if (!self.wasProcessCancelled &&
                    self.delegate)
                {
                    [self.delegate FPFileTransferControllerDidFinish:self info:[results copy]];
                }
            }
            else
            {
                self.descriptionTextField.stringValue = [NSString stringWithFormat:@"Downloading %ld of %ld file(s)", itemsProcessed + 1, totalCount];
            }
        };

        FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
            [results addObject:mediaInfo];

            markProgress();
        };

        FPFetchObjectFailureBlock failureBlock = ^(NSError * error) {
            DLog(@"Error retrieving %@: %@", item, error);

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

        // Request items

        DLog(@"shouldDownloadData = %d", self.shouldDownloadData);

        [self.sourceController requestObjectMediaInfo:item
                                       shouldDownload:self.shouldDownloadData
                                              success:successBlock
                                              failure:failureBlock
                                             progress:progressBlock];
    });
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [super cancel:sender];
    [self.sourceController cancelAllOperations];
}

@end
