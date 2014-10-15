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

@end
