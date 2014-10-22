//
//  FPNavigationHistory.m
//  FPPicker
//
//  Created by Ruben Nine on 22/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationHistory.h"

@interface FPNavigationHistory ()

@property (nonatomic, strong) NSMutableOrderedSet *items;
@property (nonatomic, assign) NSInteger currentNavIndex;

@end

@implementation FPNavigationHistory

#pragma mark - Accessors

- (NSMutableOrderedSet *)items
{
    if (!_items)
    {
        _items = [NSMutableOrderedSet orderedSet];
    }

    return _items;
}

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.currentNavIndex = -1;
    }

    return self;
}

- (BOOL)canNavigateBack
{
    if (self.currentNavIndex > 0)
    {
        return YES;
    }

    return NO;
}

- (BOOL)canNavigateForward
{
    if (self.currentNavIndex < self.items.count - 1)
    {
        return YES;
    }

    return NO;
}

- (BOOL)navigateBack
{
    if ([self canNavigateBack])
    {
        self.currentNavIndex--;

        return YES;
    }

    return NO;
}

- (BOOL)navigateForward
{
    if ([self canNavigateForward])
    {
        self.currentNavIndex++;

        return YES;
    }

    return NO;
}

- (void)addNavigationItem:(id)item
{
    @synchronized(self.items)
    {
        self.currentNavIndex++;

        if (self.items.count > self.currentNavIndex)
        {
            NSRange deleteRange = NSMakeRange(self.currentNavIndex,
                                              self.items.count - self.currentNavIndex);

            NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:deleteRange];

            [self.items removeObjectsAtIndexes:indexset];
        }

        [self.items addObject:item];
    }
}

- (void)clearNavigation
{
    @synchronized(self.items)
    {
        self.currentNavIndex = -1;
        [self.items removeAllObjects];
    }
}

- (id)currentNavigationItem
{
    if (self.currentNavIndex >= 0 &&
        self.currentNavIndex < self.items.count)
    {
        return self.items[self.currentNavIndex];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Private Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n\titems: %@\n\tcurrent Index: %ld",
            super.description,
            self.items,
            (unsigned long)self.currentNavIndex];
}

@end
