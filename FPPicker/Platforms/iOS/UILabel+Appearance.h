//
//  UILabel+Appearance.h
//  FPPicker
//
//  Created by Ruben Nine on 07/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Appearance)

- (void)setAppearanceTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setAppearanceHighlightedTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

@end
