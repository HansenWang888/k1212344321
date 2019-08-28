//
//  AddFriend.m
//  jstx
//
//  Created by macapp on 15/6/25.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportSessionApi.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
@implementation ReportSessionApi
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 0;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return MODULE_ID_SESSION;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_SESSION;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return BuddyListCmdIDCidReportSessionRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return 0;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {

    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint16_t seqNo)
    {
        
        IMReportSessionBuilder* builder = [IMReportSession builder];
        
        [builder setUserId:0];
        [builder setSessionId:[TheRuntime changeIDToOriginal:object[0]]];
        [builder setSessionType:[object[1] integerValue]];
        [builder setReasonMsg:object[2]];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [builder build].data;
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}

















@end