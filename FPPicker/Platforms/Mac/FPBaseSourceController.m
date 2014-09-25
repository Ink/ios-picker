//
//  FPBaseSourceController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPBaseSourceController.h"
#import "FPSource.h"

@interface FPBaseSourceController ()

@end

@implementation FPBaseSourceController

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.navigationSupported = YES;
        self.searchSupported = NO;
    }

    return self;
}

- (void)fpLoadContentAtPath:(BOOL)force
{
    NSAssert(NO, @"This method must be implemented by subclasses.");
}

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

- (void)setSource:(FPSource *)source
{
    _source = source;

    self.path = [NSString stringWithFormat:@"%@/", self.source.rootUrl];

    [self.serialOperationQueue cancelAllOperations];
    [self.parallelOperationQueue cancelAllOperations];
}

@end
