//
//  FPImageBrowserView.m
//  FPPicker
//
//  Created by Ruben on 9/18/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPImageBrowserView.h"
#import "FPImageBrowserCell.h"

@implementation FPImageBrowserView

- (void)mouseDown:(NSEvent *)theEvent
{
    NSInteger idx = [self indexOfItemAtLocationInWindow:theEvent.locationInWindow];

    [self dimCellAtIndexIfRequired:idx
                             state:NO];

    [super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSInteger idx = [self indexOfItemAtLocationInWindow:theEvent.locationInWindow];

    [self dimCellAtIndexIfRequired:idx
                             state:YES];

    [super mouseUp:theEvent];
}

- (void)keyDown:(NSEvent *)event
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(imageBrowser:shouldForwardKeyboardEvent:)])
    {
        if (![self.delegate imageBrowser:self
              shouldForwardKeyboardEvent:event])
        {
            return;
        }
    }

    [super keyDown:event];
}

- (IKImageBrowserCell *)newCellForRepresentedItem:(id /* <IKImageBrowserItem> */)anItem
{
    FPImageBrowserCell *cell = [FPImageBrowserCell new];

    if ([anItem respondsToSelector:@selector(isDimmed)])
    {
        cell.isDimmed = [anItem isDimmed];
    }

    return cell;
}

#pragma mark - Private Methods

- (void)dimCellAtIndexIfRequired:(NSUInteger)index
                           state:(BOOL)state
{
    if (index != NSNotFound)
    {
        FPImageBrowserCell *cell = (FPImageBrowserCell *)[self cellForItemAtIndex:index];

        if ([cell.representedItem respondsToSelector:@selector(isDimmed)] &&
            [cell.representedItem isDimmed])
        {
            cell.isDimmed = state;

            [self setNeedsDisplayInRect:cell.frame];
        }
    }
}

- (NSUInteger)indexOfItemAtLocationInWindow:(NSPoint)locationInWindow
{
    NSPoint point = [self convertPoint:locationInWindow
                              fromView:nil];

    return [self indexOfItemAtPoint:point];
}

@end
