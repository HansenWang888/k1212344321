//
//  AddFriend.m
//  jstx
//
//  Created by macapp on 15/6/25.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AcceptFriend.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
@implementation AcceptFriendAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
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
    return BuddyListCmdIDCidAcceptFriendRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidAcceptFriendRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        
        IMAcceptFriendRsp* rsp = [IMAcceptFriendRsp parseFromData:data];

        VerifyRet ret = rsp.verifyCode;
        
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
        IMAcceptFriendReqBuilder* acceptfriendreqbuilder = [IMAcceptFriendReq builder];
        [acceptfriendreqbuilder setUserId:0];
        [acceptfriendreqbuilder setFromId:[DDUserEntity localIDTopb:object]];

        
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [acceptfriendreqbuilder build].data;
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}

















@end