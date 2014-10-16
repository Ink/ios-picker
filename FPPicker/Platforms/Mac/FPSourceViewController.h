//
//  FPSourceViewController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPPickerController;
@class FPSaveController;
@class FPAuthController;
@class FPSourceBrowserController;
@class FPNavigationController;
@class FPBaseSourceController;

@interface FPSourceViewController : NSViewController

@property (nonatomic, weak) IBOutlet FPPickerController *pickerController;
@property (nonatomic, weak) IBOutlet FPSaveController *saveController;
@property (nonatomic, weak) IBOutlet FPNavigationController *navigationController;
@property (nonatomic, weak) IBOutlet FPSourceBrowserController *sourceBrowserController;
@property (nonatomic, weak) IBOutlet FPAuthController *authController;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet NSTextField *currentSelectionTextField;
@property (nonatomic, weak) IBOutlet NSTextField *filenameTextField;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;
@property (nonatomic, weak) IBOutlet NSButton *logoutButton;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;

@property (readonly, strong) FPBaseSourceController *sourceController;
@property (nonatomic, assign) BOOL allowsFileSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

- (NSString *)currentPath;
- (NSArray *)selectedItems;

- (void)cancelAllOperations;

@end
