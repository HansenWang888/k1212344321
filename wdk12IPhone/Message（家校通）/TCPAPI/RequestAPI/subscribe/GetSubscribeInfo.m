//
//  DDUserDetailInfoAPI.m
//  Duoduo
//
//  Created by madj on 14-5-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "GetSubscribeInfo.h"
#import "IMBuddy.pb.h"

#import "RuntimeStatus.h"
#import "SubscribeEntity.h"
@implementation GetSubscribeInfoAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    
    return TimeOutTimeInterval;
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
    return BuddyListCmdIDCidBuddyListSubscribeInfoRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListSubscribeInfoRespone;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        IMSubscribeInfoRsp* rsp = [IMSubscribeInfoRsp parseFromData:data];
        
        NSMutableArray* ret = [NSMutableArray new];
        if(rsp.sbInfo.count>0){
            SubscribeEntity* sbentity = [[SubscribeEntity alloc]initWithPB:rsp.sbInfo[0]];
            [ret addObject:sbentity];
            
        }
        return ret;
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
        IMSubscribeInfoReqBuilder* builder = [IMSubscribeInfoReq builder];

        

        [builder setUserId:0];
        [builder setSbUuid:object[0]];
        [builder setSbDifferno:object[1]];
        [builder setSbId:[TheRuntime changeIDToOriginal:object[2]]];
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
