//
//  FPBaseSourceController.h
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPSource.h"

@class FPBaseSourceController;

@protocol FPBaseSourceControllerDelegate <NSObject>

- (void)sourceDidStartContentLoad:(FPBaseSourceController *)sender;
- (void)source:(FPBaseSourceController *)sender didFinishContentLoad:(id)content;
- (void)source:(FPBaseSourceController *)sender didReceiveNewContent:(id)content;
- (void)source:(FPBaseSourceController *)sender didFailContentLoadWithError:(NSError *)error;

@end

@interface FPBaseSourceController : NSObject

/*!
   Parallel operation queue.
   This operation queue (unlike FPAPIClient -operationQueue)
   supports unlimited simultaneous operations.
 */
@property (nonatomic, strong) NSOperationQueue *parallelOperationQueue;

/*!
   Serial operation queue.
   This operation queue is limited to 1 simultaneous operation.
 */
@property (nonatomic, strong) NSOperationQueue *serialOperationQueue;

@property (nonatomic, assign) BOOL navigationSupported;
@property (nonatomic, assign) BOOL searchSupported;
@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *nextPage;

@property (nonatomic, weak) id<FPBaseSourceControllerDelegate>delegate;

- (void)fpLoadContentAtPath:(BOOL)force;

@end
