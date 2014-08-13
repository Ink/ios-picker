//
//  UIApplication+FPAppDimensions.h
//  FPPicker
//
//  Created by Ruben Nine on 23/07/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (FPAppDimensions)

+ (CGSize)FPCurrentSize;
+ (CGSize)FPSizeInOrientation:(UIInterfaceOrientation)orientation;

@end
