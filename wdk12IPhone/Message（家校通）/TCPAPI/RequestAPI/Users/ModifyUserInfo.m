//
//  AddFriend.m
//  jstx
//
//  Created by macapp on 15/6/25.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModifyUserInfo.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
@implementation ModifyUserInfoApi
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 3;
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
    return BuddyListCmdIDCidModifyUserinfoRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidModifyUserinfoRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMModifyUserInfoRsp* rsp = [IMModifyUserInfoRsp parseFromData:data];
        
        return @(rsp.responeTime);
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
        
        IMModifyUserInfoReqBuilder* builder = [IMModifyUserInfoReq builder];
        [builder setUserId:0];
        [builder setUpdatetype:[object[0] integerValue]];
        [builder setValue:object[1]];
        
        if(builder.updatetype == UserModifyTypeNick){
            [builder setAddtionvalue:object[2]];
        }
        if(builder.updatetype == UserModifyTypeRemark){
            [builder setContactuserId:[DDUserEntity localIDTopb:object[2]]];
        
        }
        
        
        
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