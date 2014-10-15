//
//  FPSourceViewController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPPickerController;
@class FPAuthController;
@class FPSourceBrowserController;
@class FPNavigationController;

@interface FPSourceViewController : NSViewController

@property (nonatomic, weak) IBOutlet FPPickerController *pickerController;
@property (nonatomic, weak) IBOutlet FPNavigationController *navigationController;
@property (nonatomic, weak) IBOutlet FPSourceBrowserController *sourceBrowserController;
@property (nonatomic, weak) IBOutlet FPAuthController *authController;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet NSTextField *currentSelectionTextField;
@property (nonatomic, strong) IBOutlet NSButton *loginButton;
@property (nonatomic, strong) IBOutlet NSButton *logoutButton;
@property (nonatomic, strong) IBOutlet NSTabView *tabView;
@property (nonatomic, strong) IBOutlet NSSearchField *searchField;

@property (nonatomic, assign) BOOL allowsFileSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

- (BOOL)pickSelectedItems;

@end
