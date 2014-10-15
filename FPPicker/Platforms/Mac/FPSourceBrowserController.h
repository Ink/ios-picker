//
//  FPSourceBrowserController.h
//  FPPicker
//
//  Created by Ruben Nine on 01/09/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "FPImageBrowserView.h"

@class FPSourceBrowserController;

@protocol FPSourceBrowserControllerDelegate <NSObject>

- (void)sourceBrowser:(FPSourceBrowserController *)sourceBrowserController selectionDidChange:(NSArray *)selectedItems;
- (void)sourceBrowser:(FPSourceBrowserController *)sourceBrowserController didMomentarilySelectItem:(NSDictionary *)item;

@optional

- (void)sourceBrowser:(FPSourceBrowserController *)sourceBrowserController wantsToEnterDirectoryAtPath:(NSString *)path;
- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController;

@end

@interface FPSourceBrowserController : NSObject

@property (nonatomic, weak) IBOutlet id<FPSourceBrowserControllerDelegate>delegate;
@property (nonatomic, weak) IBOutlet FPImageBrowserView *thumbnailListView;
@property (nonatomic, strong) NSArray *items;
@property (readonly, strong) NSArray *selectedItems;
@property (nonatomic, assign) BOOL allowsFileSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
