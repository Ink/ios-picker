//
//  FPSource.h
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

@import Foundation;

@interface FPSource : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *rootPath;
@property (nonatomic, strong) NSArray *openMimetypes;
@property (nonatomic, strong) NSArray *saveMimetypes;
@property (nonatomic, strong) NSArray *mimetypes;
@property (nonatomic, strong) NSArray *externalDomains;
@property (nonatomic, assign) BOOL overwritePossible;
@property (nonatomic, assign) BOOL requiresAuth;

- (NSString *)fullSourcePathForRelativePath:(NSString *)relativePath;

@end
