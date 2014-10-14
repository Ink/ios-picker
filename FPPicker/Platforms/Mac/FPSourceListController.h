//
//  FPSourceListController.h
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPSource;
@class FPSourceListController;

@protocol FPSourceListControllerDelegate <NSObject>

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPSource *)source;

@end

@interface FPSourceListController : NSViewController <NSOutlineViewDelegate,
                                                      NSOutlineViewDataSource>

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) IBOutlet id<FPSourceListControllerDelegate>delegate;

@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;

- (void)loadAndExpandSourceListIfRequired;

@end
