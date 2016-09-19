//
//  DDBCommentRow.h
//  Stopgapp
//
//  Created by Grant on 2/11/15.
//  Copyright (c) 2015 GRANTGOLDEN. All rights reserved.
//

#ifndef Stopgapp_DDBCommentRow_h
#define Stopgapp_DDBCommentRow_h


#import <Foundation/Foundation.h>
#import <AWSiOSSDKv2/DynamoDB.h>

@interface DDBCommentRow : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, assign) NSString *PostID;
@property (nonatomic, assign) NSString *CommentID;
@property (nonatomic) UInt64 Time;
@property (nonatomic, strong) NSNumber *Score;
@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) NSString *Content;

@end


#endif
