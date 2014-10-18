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

@property (nonatomic, strong) FPRepresentedSource *representedSource;
@property (nonatomic, strong) NSString *nextPage;

@property (nonatomic, weak) id <FPBaseSourceControllerDelegate> delegate;

- (void)fpLoadContentAtPath:(BOOL)force;

- (void)requestObjectMediaInfo:(NSDictionary *)obj
                shouldDownload:(BOOL)shouldDownload
                       success:(FPFetchObjectSuccessBlock)success
                       failure:(FPFetchObjectFailureBlock)failure
                      progress:(FPFetchObjectProgressBlock)progress;

- (void)cancelAllOperations;

@end
