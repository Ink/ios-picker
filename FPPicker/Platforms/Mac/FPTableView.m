//
//  FPTableView.m
//  FPPicker
//
//  Created by Ruben Nine on 21/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPTableView.h"

@implementation FPTableView

- (void)keyDown:(NSEvent *)event
{
    id <FPTableViewDelegate> theDelegate = (id)self.delegate;

    if (theDelegate &&
        [theDelegate respondsToSelector:@selector(tableView:shouldForwardKeyboardEvent:)])
    {
        if (![theDelegate tableView:self
              shouldForwardKeyboardEvent:event])
        {
            return;
        }
    }

    [super keyDown:event];
}

@end
