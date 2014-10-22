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
@property (nonatomic, assign) NSInteger currentItemIndex;

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
        self.currentItemIndex = -1;
    }

    return self;
}

- (BOOL)canNavigateBack
{
    if (self.currentItemIndex > 0)
    {
        return YES;
    }

    return NO;
}

- (BOOL)canNavigateForward
{
    if (self.currentItemIndex < self.items.count - 1)
    {
        return YES;
    }

    return NO;
}

- (BOOL)navigateBack
{
    if ([self canNavigateBack])
    {
        self.currentItemIndex--;

        return YES;
    }

    return NO;
}

- (BOOL)navigateForward
{
    if ([self canNavigateForward])
    {
        self.currentItemIndex++;

        return YES;
    }

    return NO;
}

- (void)addItem:(id)item
{
    @synchronized(self.items)
    {
        self.currentItemIndex++;

        if (self.items.count > self.currentItemIndex)
        {
            NSRange deleteRange = NSMakeRange(self.currentItemIndex,
                                              self.items.count - self.currentItemIndex);

            NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:deleteRange];

            [self.items removeObjectsAtIndexes:indexset];
        }

        [self.items addObject:item];
    }
}

- (void)clear
{
    @synchronized(self.items)
    {
        self.currentItemIndex = -1;
        [self.items removeAllObjects];
    }
}

- (id)currentItem
{
    if (self.currentItemIndex >= 0 &&
        self.currentItemIndex < self.items.count)
    {
        return self.items[self.currentItemIndex];
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
            (unsigned long)self.currentItemIndex];
}

@end
