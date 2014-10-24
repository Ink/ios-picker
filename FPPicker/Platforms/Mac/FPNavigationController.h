//
//  FPNavigationController.h
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPNavigationController;
@class FPSourcePath;

@protocol FPNavigationControllerDelegate <NSObject>

@optional

- (void)navigationController:(FPNavigationController *)navigationController selectedSourcePath:(FPSourcePath *)sourcePath;

@end

@interface FPNavigationController : NSViewController

@property (nonatomic, weak) IBOutlet id <FPNavigationControllerDelegate> delegate;

@property (nonatomic, strong) FPSourcePath *sourcePath;

- (void)refreshDirectoriesPopup;
- (void)clearNavigation;

@end
