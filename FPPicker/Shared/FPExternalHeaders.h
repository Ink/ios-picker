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

/*!
   Called after Filepicker picked a media.
 */
- (void)FPPickerController:(FPPickerController *)pickerController didPickMediaWithInfo:(FPMediaInfo *)info;

#if TARGET_OS_IPHONE

/*!
   Called after Filepicker finished picking a media.
   At this point the associated media file should be present at info.mediaURL.
   @note: iOS only.
 */
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMediaWithInfo:(FPMediaInfo *)info;

#endif

/*!
   Called after Filepicker finishing picking multiple media.
   At this point the associated media file for each item should be present at info.mediaURL.
 */
- (void)FPPickerController:(FPPickerController *)pickerController didFinishPickingMultipleMediaWithResults:(NSArray *)results;

/*!
   Typically called when the picking process is cancelled or a file can't be handled.
 */
- (void)FPPickerControllerDidCancel:(FPPickerController *)pickerController;

@end

@protocol FPSaveControllerDelegate <NSObject>

@optional

/*!
   Called after Filepicker finished saving a media.
 */
- (void)FPSaveController:(FPSaveController *)saveController didFinishSavingMediaWithInfo:(FPMediaInfo *)info;

/*!
   Called when Filepicker failed saving a media.
 */
- (void)FPSaveController:(FPSaveController *)saveController didError:(NSError *)error;

/*!
   Typically called when the save process is cancelled or a file can't be handled.
 */
- (void)FPSaveControllerDidCancel:(FPSaveController *)saveController;

@end
