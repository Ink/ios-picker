//
//  FPThumbCell.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/9/12.
//  Copyright (c) 2012 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPThumbCell.h"

@implementation FPThumbCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Initialization code
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected
              animated:animated];

    // Configure the view for the selected state
}

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
