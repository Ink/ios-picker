//
//  FPInternalHeaders.h
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSharedInternalHeaders.h"

#import "FPAuthController.h"
#import "FPUtils+iOS.h"
#import "FPLibrary+iOS.h"
#import "FPPickerController.h"
#import "FPSaveController.h"
#import "FPSourceListController.h"
#import "FPTableWithUploadButtonViewController.h"
#import "MBProgressHUD.h"

@class FPSourceController;
@class FPMediaInfo;

@protocol FPSourceControllerDelegate <NSObject>

- (void)sourceController:(FPSourceController *)sourceController didPickMediaWithInfo:(FPMediaInfo *)info;
- (void)sourceController:(FPSourceController *)sourceController didFinishPickingMediaWithInfo:(FPMediaInfo *)info;
- (void)sourceController:(FPSourceController *)sourceController didFinishPickingMultipleMediaWithResults:(NSArray *)results;
- (void)sourceControllerDidCancel:(FPSourceController *)sourceController;

@end
