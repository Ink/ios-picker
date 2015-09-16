//
//  FPTheme.h
//  FPPicker
//
//  Created by Ruben Nine on 06/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

@import UIKit;

@interface FPTheme : NSObject

/*!
   The navigation bar style that specifies its appearance (i.e., UIBarStyleDefault or UIBarStyleBlack)
 */
@property (nonatomic, assign) UIBarStyle navigationBarStyle;

/*!
   The background color to apply to the navigation bar.

   Please notice that this color will also be applied to the popover
   presentation controller's background for aesthetic purposes.
 */
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

/*!
   The tint color to apply to the navigation items and bar button items.
 */
@property (nonatomic, strong) UIColor *navigationBarTintColor;

/*!
   The tint (background) color to apply to the table view headers and footers.
 */
@property (nonatomic, strong) UIColor *headerFooterViewTintColor;

/*!
   The text color to apply to the table view headers and footers.
 */
@property (nonatomic, strong) UIColor *headerFooterViewTextColor;

/*!
   The background color to apply to the table view.
 */
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;

/*!
   The color to apply to the table view separators.
 */
@property (nonatomic, strong) UIColor *tableViewSeparatorColor;

/*!
   The background color to apply to the table view cells.
 */
@property (nonatomic, strong) UIColor *tableViewCellBackgroundColor;

/*!
   The text color to apply to the table view cells.
 */
@property (nonatomic, strong) UIColor *tableViewCellTextColor;

/*!
   The tint color to apply to the table view cells (i.e. buttons and images)
 */
@property (nonatomic, strong) UIColor *tableViewCellTintColor;

/*!
   The background color to apply to the table view cell when selected.
 */
@property (nonatomic, strong) UIColor *tableViewCellSelectedBackgroundColor;

/*!
   The text color to apply to the table view cell when selected.
 */
@property (nonatomic, strong) UIColor *tableViewCellSelectedTextColor;

/*!
   The text color to apply to the upload button given input is valid.
 */
@property (nonatomic, strong) UIColor *uploadButtonHappyTextColor;

/*!
   The text color to apply to the upload button given input is invalid.
 */
@property (nonatomic, strong) UIColor *uploadButtonAngryTextColor;

/*!
   The background color to apply to the upload button.
 */
@property (nonatomic, strong) UIColor *uploadButtonBackgroundColor;

@end
