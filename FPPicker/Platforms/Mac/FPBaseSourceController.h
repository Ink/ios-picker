//
//  FPBaseSourceController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPTypedefs.h"

@class FPBaseSourceController;
@class FPRepresentedSource;

@protocol FPBaseSourceControllerDelegate <NSObject>

- (void)sourceDidStartContentLoad:(FPBaseSourceController *)sender;
- (void)source:(FPBaseSourceController *)sender didFinishContentLoad:(id)content;
- (void)source:(FPBaseSourceController *)sender didReceiveNewContent:(id)content;
- (void)sourceController:(FPBaseSourceController *)sender didFailContentLoadWithError:(NSError *)error;

@end

@interface FPBaseSourceController : NSObject

@property (nonatomic, weak) id <FPBaseSourceControllerDelegate> delegate;

/**
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

- (instancetype)initWithRepresentedSource:(FPRepresentedSource *)representedSource NS_DESIGNATED_INITIALIZER;

- (void)loadContentsAtPathInvalidatingCache:(BOOL)invalidateCache;

@end
