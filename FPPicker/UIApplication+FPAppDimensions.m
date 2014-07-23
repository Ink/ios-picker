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

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }

    return size;
}

@end
