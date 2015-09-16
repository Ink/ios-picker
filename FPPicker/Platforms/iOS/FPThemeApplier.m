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
#import "FPBarButtonItem.h"
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

        if (theme.navigationBarBackgroundColor)
        {
            navigationController.navigationBar.barTintColor = theme.navigationBarBackgroundColor;
            navigationController.popoverPresentationController.backgroundColor = theme.navigationBarBackgroundColor;
        }

        if (theme.navigationBarTintColor)
        {
            navigationController.navigationBar.tintColor = theme.navigationBarTintColor;
        }
    }

    // Table view

    if (theme.headerFooterViewTintColor)
    {
        [UITableViewHeaderFooterView appearanceWhenContainedIn:[controller class], nil].tintColor = theme.headerFooterViewTintColor;
    }

    if (theme.headerFooterViewTextColor)
    {
        [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [controller class], nil].textColor = theme.headerFooterViewTextColor;
    }

    if (theme.tableViewBackgroundColor)
    {
        [UITableView appearanceWhenContainedIn:[controller class], nil].backgroundColor = theme.tableViewBackgroundColor;
    }

    if (theme.tableViewSeparatorColor)
    {
        [UITableView appearanceWhenContainedIn:[controller class], nil].separatorColor = theme.tableViewSeparatorColor;
    }

    if (theme.tableViewCellBackgroundColor)
    {
        [FPTableViewCell appearance].backgroundColor = theme.tableViewCellBackgroundColor;
    }

    if (theme.tableViewCellSelectedBackgroundColor)
    {
        [FPTableViewCell appearance].selectedBackgroundColor = theme.tableViewCellSelectedBackgroundColor;
    }

    if (theme.tableViewCellTintColor)
    {
        [FPTableViewCell appearance].tintColor = theme.tableViewCellTintColor;
    }

    if (theme.tableViewCellTextColor)
    {
        [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceTextColor = theme.tableViewCellTextColor;
    }

    if (theme.tableViewCellSelectedTextColor)
    {
        [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceHighlightedTextColor = theme.tableViewCellSelectedTextColor;
    }

    if (theme.uploadButtonBackgroundColor)
    {
        [FPBarButtonItem appearance].backgroundColor = theme.uploadButtonBackgroundColor;
    }


    if (theme.uploadButtonHappyTextColor)
    {
        [FPBarButtonItem appearance].happyTextColor = theme.uploadButtonHappyTextColor;
    }

    if (theme.uploadButtonAngryTextColor)
    {
        [FPBarButtonItem appearance].angryTextColor = theme.uploadButtonAngryTextColor;
    }
}

@end
