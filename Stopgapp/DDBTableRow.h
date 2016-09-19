//
//  DDBTableRow .h
//  Stopgapp
//
//  Created by Grant on 1/4/15.
//  Copyright (c) 2015 GRANTGOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSiOSSDKv2/DynamoDB.h>

@interface DDBTableRow : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, assign) NSString *PostID;
@property (nonatomic) UInt64 Time;
@property (nonatomic, strong) NSNumber *Score;
@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) NSString *Title;

@end