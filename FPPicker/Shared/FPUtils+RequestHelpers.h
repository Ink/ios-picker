//
//  FPUtils+RequestHelpers.h
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"

@interface FPUtils (RequestHelpers)

+ (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                            withType:(NSString *)type
                           mimetypes:(NSArray *)mimetypes
                         byAppending:(NSString *)additionalString
                         cachePolicy:(NSURLRequestCachePolicy)policy;

@end
