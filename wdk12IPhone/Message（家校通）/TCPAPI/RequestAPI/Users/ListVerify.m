//
//  AddFriend.m
//  jstx
//
//  Created by macapp on 15/6/25.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListVerify.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
#import "VerifyEntity.h"
@implementation ListVerifyAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 200;
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
    return BuddyListCmdIDCidBuddyListVerifyRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListVerifyRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        
        IMListVerifyRsp* rsp = [IMListVerifyRsp parseFromData:data];
        NSMutableArray* verifylist = [[NSMutableArray alloc]init];
        
        for(VerifyInfo* verifyinfo in rsp.verifyinfoList){
            VerifyEntity* entity = [[VerifyEntity alloc]initWithPB:verifyinfo];
            [verifylist addObject:entity];
        }
        
        NSLog(@"%ld",verifylist.count);
        return verifylist;
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
        IMListVerifyReqBuilder* listverifybuilder = [IMListVerifyReq builder   ];
        
        [listverifybuilder setUserId:0];
        [listverifybuilder setLastUpdatetime:0];
        
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [listverifybuilder build].data;
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}

















@end