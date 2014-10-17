//
//  FPRepresentedSource.m
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPRepresentedSource.h"

@interface FPRepresentedSource ()

@property (readwrite, nonatomic) FPSource *source;

@end

@implementation FPRepresentedSource

#pragma mark - Accessors

- (NSOperationQueue *)parallelOperationQueue
{
    if (!_parallelOperationQueue)
    {
        _parallelOperationQueue = [NSOperationQueue new];
    }

    return _parallelOperationQueue;
}

- (NSOperationQueue *)serialOperationQueue
{
    if (!_serialOperationQueue)
    {
        _serialOperationQueue = [NSOperationQueue new];
        _serialOperationQueue.maxConcurrentOperationCount = 1;
    }

    return _serialOperationQueue;
}

- (void)cancelAllOperations
{
    DLog(@"Cancelling all operations on %@", self);

    [self.serialOperationQueue cancelAllOperations];
    [self.parallelOperationQueue cancelAllOperations];
}

#pragma mark - Public Methods

- (instancetype)initWithSource:(FPSource *)source
{
    self = [super init];

    if (self)
    {
        self.source = source;
        self.isLoggedIn = NO;
        self.currentPath = [NSString stringWithFormat:@"%@/", source.rootUrl];
    }

    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (currentPath: %@, isLoggedIn: %@",
            [super description],
            self.currentPath,
            self.isLoggedIn ? @"YES" :@"NO"];
}

@end
