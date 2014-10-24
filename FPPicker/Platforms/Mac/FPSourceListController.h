//
//  FPSourceListController.h
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPRepresentedSource;
@class FPSourceListController;
@class FPSource;

@protocol FPSourceListControllerDelegate <NSObject>

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPRepresentedSource *)representedSource;

- (void)sourceListController:(FPSourceListController *)sourceListController
         didLogoutFromSource:(FPRepresentedSource *)representedSource;

@end

@interface FPSourceListController : NSViewController <NSOutlineViewDelegate,
                                                      NSOutlineViewDataSource>

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) IBOutlet id <FPSourceListControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;

- (void)loadAndExpandSourceList;
- (void)refreshOutline;
- (void)cancelAllOperations;
- (void)selectSource:(FPSource *)source;
- (FPSource *)selectedSource;

@end
