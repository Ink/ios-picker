//
//  FPTableCellView.m
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPTableCellView.h"

@implementation FPTableCellView

- (void)awakeFromNib
{
    [super awakeFromNib];

    // We want it to appear "inline"

    [[self.button cell] setBezelStyle:NSInlineBezelStyle];
}

// The standard rowSizeStyle does some specific layout for us. To customize layout for our button, we first call super and then modify things

- (void)viewWillDraw
{
    [super viewWillDraw];

    if (![self.button isHidden])
    {
        [self.button sizeToFit];

        NSRect textFrame = self.textField.frame;
        NSRect buttonFrame = self.button.frame;
        buttonFrame.origin.x = NSWidth(self.frame) - NSWidth(buttonFrame);
        self.button.frame = buttonFrame;
        textFrame.size.width = NSMinX(buttonFrame) - NSMinX(textFrame);
        self.textField.frame = textFrame;
    }
}

@end
