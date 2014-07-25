//
//  FPConfig.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

@interface FPConfig : NSObject

@property (nonatomic, readonly, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSString *appSecretKey;
@property (nonatomic, strong) NSString *storeAccess;
@property (nonatomic, strong) NSString *storeLocation;
@property (nonatomic, strong) NSString *storePath;
@property (nonatomic, strong) NSString *storeContainer;

+ (instancetype)sharedInstance;

@end
