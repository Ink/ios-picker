//
//  FPUtils+RequestHelpers.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils+RequestHelpers.h"
#import "FPPrivateConfig.h"
#import "FPSession.h"

@implementation FPUtils (RequestHelpers)

+ (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                            withType:(NSString *)type
                           mimetypes:(NSArray *)mimetypes
                         byAppending:(NSString *)additionalString
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;
    fpSession.mimetypes = mimetypes;

    NSString *escapedSessionString = [self urlEncodeString:[fpSession JSONSessionString]];
    const char concatChar = ([loadpath rangeOfString:@"?"].location == NSNotFound) ? '?' : '&';

    NSString *urlString = [NSString stringWithFormat:@"%@/api/path%@%cformat=%@&js_session=%@%@",
                           fpBASE_URL,
                           loadpath,
                           concatChar,
                           type,
                           escapedSessionString,
                           additionalString];

    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:policy
                                                        timeoutInterval:240];

    [mRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return [mRequest copy];
}

@end
