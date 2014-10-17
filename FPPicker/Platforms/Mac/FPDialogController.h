//
//  FPDialogController.h
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPBaseSourceController;
@class FPRepresentedSource;

@interface FPDialogController : NSObject

@property (nonatomic, weak) IBOutlet NSWindow *window;

- (void)setupSourceListWithSourceNames:(NSArray *)sourceNames
                          andDataTypes:(NSArray *)dataTypes;

- (void)cancelAllOperations;
- (void)setupDialogForSavingWithDefaultFileName:(NSString *)filename;

- (NSString *)filenameFromSaveTextField;
- (NSString *)currentPath;
- (NSArray *)selectedItems;
- (FPBaseSourceController *)selectedSourceController;

@end
