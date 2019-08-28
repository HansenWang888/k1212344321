//
//  SubscribeAttentionAPI.m
//  wdk12pad
//
//  Created by macapp on 16/2/1.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SearchSubscribeAPI.h"
#import "IMBuddy.pb.h"
#import "SubscribeEntity.h"
@implementation SearchSubscribeAPI
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
    return BuddyListCmdIDCidBuddyListSearchSubscribeRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListSearchSubscribeResponse;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        NSMutableArray* ret = [NSMutableArray new];
        IMSearchSubscribeRsp* rsp = [IMSearchSubscribeRsp parseFromData:data];
        [rsp.sbList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SubscribeEntity* sbentity = [[SubscribeEntity alloc]initWithPB:obj];
            [ret addObject:sbentity];
        }];
        
        
        
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
        IMSearchSubscribeReqBuilder* builder = [IMSearchSubscribeReq builder];
        [builder setUserId:0];
        [builder setSearchkey:object];

        
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
