//
//  FPThumbCell.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/9/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPThumbCell.h"

@implementation FPThumbCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(5, 5, 34, 34);
    self.imageView.clipsToBounds = YES;

    CGFloat limgW = self.imageView.image.size.width;

    if (limgW > 0)
    {
        CGRect textLabelFrame = self.textLabel.frame;
        CGRect detailTextLabelFrame = self.detailTextLabel.frame;

        textLabelFrame.origin.x = 50;
        detailTextLabelFrame.origin.x = 50;

        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
    }
}

@end
