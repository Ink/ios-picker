//
//  UIApplication+FPAppDimensions.m
//  FPPicker
//
//  Created by Ruben Nine on 23/07/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "UIApplication+FPAppDimensions.h"

@implementation UIApplication (FPAppDimensions)

+ (CGSize)FPCurrentSize
{
    return [self FPSizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGSize)FPSizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;

    // In iOS 7.1 and earlier [UIScreen mainScreen].bounds does not take orientation into
    // consideration, so we need to detect landscape mode and exchange width <-> height.
    // In iOS 8 this is no longer necessary because [UIScreen bounds] is now interface-oriented.

    if (SYSTEM_VERSION_LESS_THAN(@"8.0") &&
        UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }

    return size;
}

@end
