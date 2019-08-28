//
//  DDUserDetailInfoAPI.m
//  Duoduo
//
//  Created by madj on 14-5-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "SearchUser.h"
#import "IMBuddy.pb.h"

#import "RuntimeStatus.h"
#import "DDUserEntity.h"
#import "SubscribeEntity.h"
@implementation SearchUserAPI
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
    return BuddyListCmdIDCidBuddyListSearchUserRequest;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return BuddyListCmdIDCidBuddyListSearchUserResponse;
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
        
        
        IMSearchUserRsp* rsp = [IMSearchUserRsp parseFromData:data];
        NSMutableArray* userList = [[NSMutableArray alloc]init];
        for (UserInfo *userInfo in rsp.userList) {
            DDUserEntity *user = [[DDUserEntity alloc] initWithPB:userInfo];
            [userList addObject:user];
        }
        NSMutableArray* sbList = [[NSMutableArray alloc]init];
        for(SubscribeInfo* sbinfo in rsp.sbList){
            SubscribeEntity* sb = [[SubscribeEntity alloc]initWithPB:sbinfo];
            [sbList addObject:sb];
        }
        
        return @[userList,sbList];
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
        NSString * searchkey = object;
        IMSearchUserReqBuilder* searchreqbuilder = [IMSearchUserReq builder];
        [searchreqbuilder setSearchkey:searchkey   ];
        [searchreqbuilder setUserId:0  ];
        

        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];

        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        NSData* _data = [searchreqbuilder build].data;
             
        
        [dataout directWriteBytes:_data];
        
        [dataout writeDataCount];
        
        
        return [dataout toByteArray];
    };
    return package;
}
@end
