//
//  FPBaseSourceController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPBaseSourceController.h"
#import "FPInternalHeaders.h"

@interface FPBaseSourceController ()

@property (nonatomic, strong) FPRepresentedSource *representedSource;

@end

@implementation FPBaseSourceController

#pragma mark - Public Methods

- (instancetype)initWithRepresentedSource:(FPRepresentedSource *)representedSource
{
    self = [super init];

    if (self)
    {
        self.representedSource = representedSource;
    }

    return self;
}

- (void)loadContentsAtPathInvalidatingCache:(BOOL)invalidateCache
{
    NSAssert(NO, @"This method must be implemented by subclasses.");
}

@end
