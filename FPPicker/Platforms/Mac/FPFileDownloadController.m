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
#import "FPLibrary.h"

@interface FPFileDownloadController ()

@property (readwrite, nonatomic, strong) NSArray *items;
@property (nonatomic, strong) FPProgressTracker *progressTracker;
@property (nonatomic, strong) FPRepresentedSource *representedSource;

@end

@implementation FPFileDownloadController

- (instancetype)initWithItems:(NSArray *)items
         andRepresentedSource:(FPRepresentedSource *)representedSource
{
    self = [super init];

    if (self)
    {
        self.items = items;
        self.representedSource = representedSource;
    }

    return self;
}

#pragma mark - Public Methods

- (void)process
{
    // Check there's items

    if (self.items.count == 0)
    {
        return;
    }

    // Check there's a delegate

    if (!self.delegate)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Delegate must be present."];

        return;
    }

    // Check there's a represented source

    if (!self.representedSource)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Represented source must be present."];

        return;
    }

    // Call super

    [super process];

    // Initialize variables, etc.

    NSUInteger totalCount = self.items.count;
    NSMutableArray *results = [NSMutableArray array];

    __block NSUInteger itemsProcessed = 0;
    __block BOOL hasStarted = NO;

    self.descriptionTextField.stringValue = [NSString stringWithFormat:@"About to start downloading %ld file(s)", totalCount];

    [self.progressIndicator startAnimation:self];

    self.progressTracker = [[FPProgressTracker alloc] initWithObjectCount:totalCount];

    // Start processing

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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressIndicator stopAnimation:self];
                    [self.window close];
                });

                if (self.delegate)
                {
                    [self.delegate FPFileTransferControllerDidFinish:self
                                                                info:[results copy]];
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
            DLog(@"Error retrieving %@: %@", item[@"link_path"], error.localizedDescription);

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

        [FPLibrary requestObjectMediaInfo:item
                               withSource:self.representedSource.source
                      usingOperationQueue:self.operationQueue
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progressBlock];
    });
}

@end
