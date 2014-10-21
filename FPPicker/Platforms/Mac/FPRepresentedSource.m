//
//  FPRepresentedSource.m
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPRepresentedSource.h"

@interface FPRepresentedSource ()

@property (readwrite) NSOperationQueue *parallelOperationQueue;
@property (readwrite) NSOperationQueue *serialOperationQueue;
@property (readwrite) FPSource *source;
@property (readwrite) FPSourcePath *sourcePath;

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
    if (self.serialOperationQueue.operationCount > 0 ||
        self.parallelOperationQueue.operationCount > 0)
    {
        DLog(@"Cancelling all operations on %@", self);

        [self.serialOperationQueue cancelAllOperations];
        [self.parallelOperationQueue cancelAllOperations];
    }
}

- (void)setCurrentPath:(NSString *)currentPath
{
    _currentPath = currentPath;

    self.sourcePath = [[FPSourcePath alloc] initWithSource:self.source
                                                   andPath:self.currentPath];
}

#pragma mark - Public Methods

- (instancetype)initWithSource:(FPSource *)source
{
    self = [super init];

    if (self)
    {
        self.source = source;
        self.isLoggedIn = NO;
        self.currentPath = [NSString stringWithFormat:@"%@/", source.rootPath];
    }

    return self;
}

- (NSString *)rootPath
{
    return self.sourcePath.rootPath;
}

- (NSString *)parentPath
{
    return self.sourcePath.parentPath;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n\tcurrentPath = %@\n\tisLoggedIn = %@\n\tpending operations = {s: %ld p: %ld}\n\tsource = %@\n}",
            super.description,
            self.currentPath,
            self.isLoggedIn ? @"YES" :@"NO",
            (unsigned long)self.serialOperationQueue.operationCount,
            (unsigned long)self.parallelOperationQueue.operationCount,
            self.source.identifier];
}

@end
