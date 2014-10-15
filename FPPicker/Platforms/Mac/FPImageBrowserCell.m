//
//  FPImageBrowserCell.m
//  FPPicker
//
//  Created by Ruben Nine on 15/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPImageBrowserCell.h"

@implementation FPImageBrowserCell

- (CGFloat)opacity
{
    return self.isDimmed ? 0.5 : 1.0;
}

@end
