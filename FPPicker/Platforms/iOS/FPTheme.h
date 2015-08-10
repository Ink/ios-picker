//
//  FPTheme.h
//  FPPicker
//
//  Created by Ruben Nine on 06/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

@import UIKit;

@interface FPTheme : NSObject

@property (nonatomic, assign) UIBarStyle navigationBarStyle;
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;
@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) UIColor *footerViewTintColor;
@property (nonatomic, strong) UIColor *headerFooterViewTextColor;
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewSeparatorColor;
@property (nonatomic, strong) UIColor *tableViewCellBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewCellTextColor;
@property (nonatomic, strong) UIColor *tableViewCellTintColor;
@property (nonatomic, strong) UIColor *tableViewCellSelectedBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewCellSelectedTextColor;
@property (nonatomic, strong) UIColor *uploadButtonHappyTextColor;
@property (nonatomic, strong) UIColor *uploadButtonAngryTextColor;
@property (nonatomic, strong) UIColor *uploadButtonBackgroundColor;

@end
