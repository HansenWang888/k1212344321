//
//  SubjectListRequest.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SubjectList;

@interface SubjectListRequest : NSObject

// TODO: 作业起始条数和预习起始条数由后台告诉，不需要关心，只需传入页数
///  pgaeSize
@property (nonatomic, assign) int myts;
///  作业起始条数
@property (nonatomic, copy) NSString *zyqs;
///  预习起始条数
@property (nonatomic, copy) NSString *yxqs;
///  科目id
@property (nonatomic, copy) NSString *kmID;

- (void)fetchNextPageModels:(void (^)(NSArray *data))handler;
- (void)fetchFirstPageModels:(void (^)(NSArray *data))handler;

@end
