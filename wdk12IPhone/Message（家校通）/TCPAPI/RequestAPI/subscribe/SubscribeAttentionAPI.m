//
//  SubscribeAttentionAPI.m
//  wdk12pad
//
//  Created by macapp on 16/2/1.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeAttentionAPI.h"
#import "IMBuddy.pb.h"
@implementation SubscribeAttentionAPI
- (int)requestTimeOutTimeInterval
{
    return 5;
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
    return BuddyListCmdIDCidBuddyListSubscribeAttentionRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListSubscribeAttentionRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        
        IMSubscribeAttentionRsp* rsp = [IMSubscribeAttentionRsp parseFromData:data];
        
        SubscribeRetCode ret = rsp.resultCode;
        
        return @(ret);
        
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
        IMSubscribeAttentionReqBuilder* attentionbuilder = [IMSubscribeAttentionReq builder];

        [attentionbuilder setUserId:0];
        
        [attentionbuilder setSbUuid:object[0]];
        
        [attentionbuilder setOpt:[object[1] integerValue]];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [attentionbuilder build].data;
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}






@end
