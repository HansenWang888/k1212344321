//
//  DDAllUserAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAllUserAPI.h"
#import "DDUserEntity.h"
#import "IMBuddy.pb.h"
#import "ContactInfo.h"
@implementation DDAllUserAPI
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
    return CMD_FRI_ALL_USER_REQ;
}

/**
 *  请求返回的commendID
 * 
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_ALL_USER_RES;
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
        IMAllUserRsp *allUserRsp = [IMAllUserRsp parseFromData:data];
        uint32_t alllastupdatetime = allUserRsp.latestUpdateTime;
        NSMutableDictionary *userAndVersion = [NSMutableDictionary new];
        [userAndVersion setObject:@(alllastupdatetime) forKey:@"contactupdatetime"];
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        for (ContactInfo *contactinfo in allUserRsp.contactList) {
            
            ContactInfoEntity* entity = [[ContactInfoEntity alloc]initWithPB:contactinfo];
            [userList addObject:entity];
            

        }
       
//        for (uint32_t i = 0; i < userCnt; i++) {
//            NSString *userId =[bodyData readUTF];
//            uint32_t version = [bodyData readInt];
//            NSDictionary* result = nil;
//            result = @{
//                       @"userId":userId,
//                       @"version":@(version),
//                       };
//            DDUserEntity *user = [DDUserEntity dicToUserEntity:result];
//            [userList addObject:user];
//        
//        }
        [userAndVersion setObject:userList forKey:@"userlist"];
        return userAndVersion;
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
    Package package = (id)^(id object,uint32_t seqNo)
    {
        IMAllUserReqBuilder *reqBuilder = [IMAllUserReq builder];
        NSInteger version = [object[0] integerValue];
        [reqBuilder setUserId:0];
        [reqBuilder setLatestUpdateTime:version];

        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_SESSION
                                    cId:CMD_FRI_ALL_USER_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
