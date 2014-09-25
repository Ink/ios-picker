//
//  FPSourceViewController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPBaseSourceController.h"

@class FPSource;
@class FPAuthController;
@class FPSourceBrowserController;
@class FPNavigationController;

@interface FPSourceViewController : NSViewController

@property (nonatomic, weak) IBOutlet FPNavigationController *navigationController;
@property (nonatomic, weak) IBOutlet FPSourceBrowserController *sourceBrowserController;
@property (nonatomic, weak) IBOutlet FPAuthController *authController;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) IBOutlet NSButton *loginButton;
@property (nonatomic, strong) IBOutlet NSButton *logoutButton;
@property (nonatomic, strong) IBOutlet NSTabView *tabView;
@property (nonatomic, strong) IBOutlet NSSearchField *searchField;

@end
