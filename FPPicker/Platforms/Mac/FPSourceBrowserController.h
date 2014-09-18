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

@optional

- (void)          sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
    wantsToPerformActionOnItems:(NSArray *)items;

- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController;

@end

@interface FPSourceBrowserController : NSObject

@property (nonatomic, weak) IBOutlet id<FPSourceBrowserControllerDelegate>delegate;
@property (nonatomic, weak) IBOutlet FPImageBrowserView *thumbnailListView;
@property (nonatomic, strong) NSArray *items;

@end
