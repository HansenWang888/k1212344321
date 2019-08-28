//
//  AddFriend.m
//  jstx
//
//  Created by macapp on 15/6/25.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddFriend.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
@implementation AddFriendApi
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
    return BuddyListCmdIDCidAddFriendRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidAddFriendRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMAddFriendRsp* rsp = [IMAddFriendRsp parseFromData:data];
    
        return @(rsp.verifyCode);
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
        IMAddFriendReqBuilder* addfriendreqbuilder = [IMAddFriendReq builder];
        [addfriendreqbuilder setUserId:0];
        [addfriendreqbuilder setToId:[DDUserEntity localIDTopb:object[0]]];
        [addfriendreqbuilder setVerify:object[1]];
        

        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [addfriendreqbuilder build].data;
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}

















@end