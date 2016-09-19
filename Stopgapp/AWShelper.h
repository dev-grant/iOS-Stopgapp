//
//  AWShelper.h
//  Stopgapp
//
//  Created by Grant on 1/1/15.
//  Copyright (c) 2015 GRANTGOLDEN. All rights reserved.
//

#ifndef Stopgapp_AWShelper_h
#define Stopgapp_AWShelper_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AWShelper : NSObject

+(void)setupCognito;
+(NSString *)uploadPhoto: (UIImage*)image;
+(NSString *)generateUuidString;

+(unsigned long long)currentTime;

@end

#endif
