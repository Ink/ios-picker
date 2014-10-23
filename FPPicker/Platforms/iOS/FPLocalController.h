//
//  FPLocalController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FPInternalHeaders.h"

@interface FPLocalController : FPTableWithUploadButtonViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) FPSource *source;
@property (nonatomic, weak) id <FPSourceControllerDelegate> fpdelegate;
@property (nonatomic, retain) ALAssetsGroup *assetGroup;

@end
