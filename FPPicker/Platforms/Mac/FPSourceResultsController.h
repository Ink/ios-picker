//
//  FPSourceResultsController.h
//  FPPicker
//
//  Created by Ruben Nine on 01/09/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "FPImageBrowserView.h"

@class FPSourceResultsController;

@protocol FPSourceResultsControllerDelegate <NSObject>

- (void)sourceResults:(FPSourceResultsController *)sourceResultsController selectionDidChange:(NSArray *)selectedItems;
- (void)sourceResults:(FPSourceResultsController *)sourceResultsController didMomentarilySelectItem:(NSDictionary *)item;

@optional

- (void)sourceResults:(FPSourceResultsController *)sourceResultsController doubleClickedOnItems:(NSArray *)items;
- (void)sourceResults:(FPSourceResultsController *)sourceResultsController wantsToEnterDirectoryAtPath:(NSString *)path;
- (void)sourceResultsWantsToGoUpOneDirectory:(FPSourceResultsController *)sourceResultsController;

@end

@interface FPSourceResultsController : NSObject

@property (nonatomic, weak) IBOutlet id <FPSourceResultsControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *items;
@property (readonly, strong) NSArray *selectedItems;
@property (nonatomic, assign) BOOL allowsFileSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

- (void)reloadData;
- (void)appendItems:(NSArray *)items;

@end
