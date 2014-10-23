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

- (void)FPPickerController:(FPPickerController *)pickerController didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)FPPickerControllerDidCancel:(FPPickerController *)pickerController;

@end

@protocol FPSaveDelegate <NSObject>

@optional

- (void)FPSaveController:(FPSaveController *)saveController didFinishSavingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSaveController:(FPSaveController *)saveController didError:(NSError *)error;
- (void)FPSaveControllerDidCancel:(FPSaveController *)saveController;

@end

@class FPSourceController;

@protocol FPSourcePickerDelegate <NSObject>

- (void)FPSourceController:(FPSourceController *)sourceController didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceController:(FPSourceController *)sourceController didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSourceController:(FPSourceController *)sourceController didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)FPSourceControllerDidCancel:(FPSourceController *)sourceController;

@end
