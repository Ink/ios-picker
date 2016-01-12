//
//  FPSinglepartUploader.m
//  FPPicker
//
//  Created by Ruben Nine on 16/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPUploader_protected

#import "FPSinglepartUploader.h"
#import "FPSession+ConvenienceMethods.h"

@implementation FPSinglepartUploader

- (void)doUpload
{
    AFConstructingBodyBlock constructingBodyBlock = ^(id <AFMultipartFormData> formData) {
        NSData *filedata = [NSData dataWithContentsOfURL:self.localURL];

        [formData appendPartWithFileData:filedata
                                    name:@"fileUpload"
                                fileName:self.filename
                                mimeType:self.mimetype];
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if ([@"ok" isEqualToString:responseObject[@"result"]])
        {
            self.successBlock(responseObject);
            self.hasFinished = YES;
        }
        else
        {
            self.failureBlock([[NSError alloc] initWithDomain:@"FPPicker"
                                                         code:0
                                                     userInfo:nil], responseObject);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        self.failureBlock(error, nil);
    };

    NSDictionary *params = @{
        @"js_session":self.js_sessionString
    };

    AFHTTPRequestOperation *operation = [[FPAPIClient sharedClient] POST:@"/api/upload/"
                                                              parameters:params
                                               constructingBodyWithBlock:constructingBodyBlock
                                                     usingOperationQueue:self.operationQueue
                                                                 success:successOperationBlock
                                                                 failure:failureOperationBlock];

    [operation setUploadProgressBlock: ^(NSUInteger bytesWritten,
                                         long long totalBytesWritten,
                                         long long totalBytesExpectedToWrite) {
        if (self.progressBlock &&
            totalBytesExpectedToWrite > 0)
        {
            self.progressBlock(1.0f * totalBytesWritten / totalBytesExpectedToWrite);
        }
    }];
}

@end
