//
//  FPExternalHeaders.h
//  FPPicker
//
//  Created by Liyan David Chang on 7/8/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPPickerController;
@class FPSaveController;
@class FPMediaInfo;

@protocol FPPickerDelegate <NSObject>

@optional

- (void)FPPickerController:(FPPickerController *)picker didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker;

@end

@protocol FPSaveDelegate <NSObject>

@optional

- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSaveController:(FPSaveController *)picker didError:(NSDictionary *)info;
- (void)FPSaveControllerDidCancel:(FPSaveController *)picker;
- (void)FPSaveControllerDidSave:(FPSaveController *)picker;

@end

@class FPSourceController;

@protocol FPSourcePickerDelegate <NSObject>

- (void)FPSourceController:(FPSourceController *)picker didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)FPSourceControllerDidCancel:(FPSourceController *)picker;

@end

@protocol FPSourceSaveDelegate <NSObject>

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *dataurl;
@property (nonatomic, strong) NSString *dataType;

- (void)FPSourceController:(FPSourceController *)picker didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceControllerDidCancel:(FPSourceController *)picker;

@end
