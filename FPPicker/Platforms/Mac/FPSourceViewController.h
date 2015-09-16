//
//  FPSourceViewController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPSourceResultsController;
@class FPAuthController;
@class FPBaseSourceController;
@class FPSourceViewController;
@class FPRepresentedSource;
@class FPSourcePath;

@protocol FPSourceViewControllerDelegate <NSObject>

@optional

- (void)sourceViewController:(FPSourceViewController *)sourceViewController representedSourceLoginStatusChanged:(FPRepresentedSource *)representedSource;

- (void)sourceViewController:(FPSourceViewController *)sourceViewController didMomentarilySelectFilename:(NSString *)filename;

- (void)sourceViewController:(FPSourceViewController *)sourceViewController sourcePathChanged:(FPSourcePath *)sourcePath;

- (void)sourceViewController:(FPSourceViewController *)sourceViewController doubleClickedOnItems:(NSArray *)items;

@end

@interface FPSourceViewController : NSViewController

@property (nonatomic, weak) IBOutlet FPSourceResultsController *sourceResultsController;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet NSTextField *currentSelectionTextField;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet id <FPSourceViewControllerDelegate> delegate;

@property (nonatomic, strong) FPRepresentedSource *representedSource;
@property (nonatomic, strong, readonly) FPBaseSourceController *sourceController;
@property (nonatomic, assign) BOOL allowsFileSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

- (NSString *)currentPath;
- (NSArray *)selectedItems;

- (void)loadPath:(NSString *)path;

@end
