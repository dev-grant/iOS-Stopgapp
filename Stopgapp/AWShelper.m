//
//  AWShelper.m
//  Stopgapp
//
//  Created by Grant on 1/1/15.
//  Copyright (c) 2015 GRANTGOLDEN. All rights reserved.
//


#include "AWShelper.h"

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSCognitoSync/Cognito.h>
#import <AWSiOSSDKv2/S3.h>

@implementation AWShelper


+(void)setupCognito{
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:@"097638860670"
                                                          identityPoolId:@"us-east-1:9b8747ac-f0e7-49dc-942f-aa6a0fb2f6c3"
                                                          unauthRoleArn:@"arn:aws:iam::097638860670:role/Cognito_stopgappawsUnauth_DefaultRole"
                                                          authRoleArn:@"arn:aws:iam::097638860670:role/Cognito_stopgappawsAuth_DefaultRole"];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    [[credentialsProvider getIdentityId] continueWithBlock:^id(BFTask *task) {
        NSLog(@"Identity ID = [%@]", credentialsProvider.identityId);
        return nil;
    }];
    
}

+(NSString *)uploadPhoto: (UIImage*)image{
    
    /*CGImageRef imageRef = [image CGImage];
    
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
     */
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.jpeg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:tempPath atomically:YES];
    
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:tempPath];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"stopgappaws";
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
    NSString *postID = [self generateUuidString];
    NSString *imageName = [postID stringByAppendingString:@".jpeg"];
    uploadRequest.key = imageName;
    
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.body = url;
    
    uploadRequest.uploadProgress =^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            
        });
    };
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
        }else{
            //success
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            
        }
        return nil;
    }];
    
    return postID;
}

+ (unsigned long long)currentTime{
    NSDate *date = [NSDate date];
    unsigned long long l = floor([date timeIntervalSinceReferenceDate]*1000);
    return l;
}

+ (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    

    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

@end