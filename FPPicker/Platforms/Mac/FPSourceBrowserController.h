//
//  FPSourceBrowserController.h
//  FPPicker
//
//  Created by Ruben Nine on 01/09/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface FPSourceBrowserController : NSObject

@property (nonatomic, weak) IBOutlet IKImageBrowserView *thumbnailListView;
@property (nonatomic, strong) NSArray *items;

@end
