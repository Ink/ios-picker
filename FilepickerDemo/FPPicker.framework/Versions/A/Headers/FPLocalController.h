//
//  FPLocalController.h
//  filepicker
//
//  Created by Liyan David Chang on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FPLibrary.h"

@interface FPLocalController : UITableViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, assign) id <FPSourcePickerDelegate> fpdelegate;


@end
