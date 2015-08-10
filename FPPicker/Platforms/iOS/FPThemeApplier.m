//
//  FPThemeApplier.m
//  FPPicker
//
//  Created by Ruben Nine on 07/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import "FPThemeApplier.h"
#import "FPPickerController.h"
#import "UILabel+Appearance.h"
#import "FPTableViewCell.h"
#import "FPThumbCell.h"
#import "FPLocalController.h"

@interface FPThemeApplier ()

@property (readwrite) FPTheme *theme;

@end

@implementation FPThemeApplier

- (instancetype)initWithTheme:(FPTheme *)theme;
{
    self = [super init];

    if (self)
    {
        self.theme = theme;
    }

    return self;
}

- (void)applyToController:(id)controller
{
    FPTheme *theme = self.theme;

    // Navigation bar

    if ([controller isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)controller;

        navigationController.navigationBar.barStyle = theme.navigationBarStyle;
        navigationController.navigationBar.barTintColor = theme.navigationBarBackgroundColor;
        navigationController.navigationBar.tintColor = theme.navigationBarTintColor;
    }

    // Table view

    [UITableViewHeaderFooterView appearanceWhenContainedIn:[controller class], nil].tintColor = theme.footerViewTintColor;
    [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [controller class], nil].textColor = theme.headerFooterViewTextColor;
    [UITableView appearanceWhenContainedIn:[controller class], nil].backgroundColor = theme.tableViewBackgroundColor;
    [UITableView appearanceWhenContainedIn:[controller class], nil].separatorColor = theme.tableViewSeparatorColor;

    [FPTableViewCell appearance].backgroundColor = theme.tableViewCellBackgroundColor;
    [FPTableViewCell appearance].selectedBackgroundColor = theme.tableViewCellSelectedBackgroundColor;
    [FPTableViewCell appearance].tintColor = theme.tableViewCellTintColor;

    [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceTextColor = theme.tableViewCellTextColor;
    [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceHighlightedTextColor = theme.tableViewCellSelectedTextColor;
}

@end
