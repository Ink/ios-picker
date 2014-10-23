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

@protocol FPPickerControllerDelegate <NSObject>

@optional

- (void)FPPickerController:(FPPickerController *)pickerController didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)FPPickerControllerDidCancel:(FPPickerController *)pickerController;

@end

@protocol FPSaveControllerDelegate <NSObject>

@optional

- (void)FPSaveController:(FPSaveController *)saveController didFinishSavingMediaWithInfo:(FPMediaInfo *)info;
- (void)FPSaveController:(FPSaveController *)saveController didError:(NSError *)error;
- (void)FPSaveControllerDidCancel:(FPSaveController *)saveController;

@end
