//
//  DDAddMemberToGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "QuitGroupapi.h"
#import "DDGroupModule.h"
#import "GroupEntity.h"
#import "RuntimeStatus.h"
#import "IMGroup.pb.h"
@implementation QuitGroupApi
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
    return SERVICE_GROUP;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return SERVICE_GROUP;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_ID_GROUP_CHANGE_GROUP_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_CHANGE_GROUP_RES;
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
        
        IMGroupChangeMemberRsp *rsp = [IMGroupChangeMemberRsp parseFromData:data];
        
        uint32_t result =rsp.resultCode;
        NSMutableArray *array = [NSMutableArray new];
        
        if(result == 0){
            NSUInteger userCnt = [rsp.curUserIdList count];
            
            for (NSUInteger i = 0; i < userCnt; i++) {
                NSString* userId = [TheRuntime changeOriginalToLocalID:[rsp.curUserIdList[i] integerValue] SessionType:SessionTypeSessionTypeSingle];
                [array addObject:userId];
            }
        }
        return @[@(result),array];
        
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
        NSArray* array = (NSArray*)object;
        NSString* groupId = array[0];
        IMGroupChangeMemberReqBuilder *memberChange = [IMGroupChangeMemberReq builder];
        [memberChange setUserId:0];
        [memberChange setChangeType:GroupModifyTypeGroupModifyTypeQuit];
        [memberChange setGroupId:[TheRuntime changeIDToOriginal:groupId]];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SERVICE_GROUP cId:CMD_ID_GROUP_CHANGE_GROUP_REQ seqNo:seqNo];
        [dataout directWriteBytes:[memberChange build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
