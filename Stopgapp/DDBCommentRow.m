//
//  DDBCommentRow.m
//  Stopgapp
//
//  Created by Grant on 2/11/15.
//  Copyright (c) 2015 GRANTGOLDEN. All rights reserved.
//

#import <AWSiOSSDKv2/DynamoDB.h>
#import "DDBTableRow.h"

@implementation DDBTableRow


+ (NSString *)dynamoDBTableName {
    return @"comments";
}


+ (NSString *)hashKeyAttribute {
    return @"PostID";
}

 + (NSString *)rangeKeyAttribute {
     return @"CommentID";
 }
 

@end