//
//  FPRemoteSourceController.h
//  FPPicker Mac
//
//  Created by Ruben Nine on 07/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPBaseSourceController.h"

@class FPRemoteSourceController;

@protocol FPRemoteSourceControllerDelegate <FPBaseSourceControllerDelegate>

- (void)remoteSourceRequiresAuthentication:(FPRemoteSourceController *)sender;

@end


@interface FPRemoteSourceController : FPBaseSourceController

@property (nonatomic, weak) id<FPRemoteSourceControllerDelegate>delegate;

@end
