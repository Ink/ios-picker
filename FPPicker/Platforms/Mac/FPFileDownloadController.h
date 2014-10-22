//
//  FPFileDownloadController.h
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileTransferController.h"

@class FPRepresentedSource;

@interface FPFileDownloadController : FPFileTransferController

@property (nonatomic, assign) BOOL shouldDownloadData;

- (instancetype)initWithItems:(NSArray *)items
         andRepresentedSource:(FPRepresentedSource *)representedSource;

@end
