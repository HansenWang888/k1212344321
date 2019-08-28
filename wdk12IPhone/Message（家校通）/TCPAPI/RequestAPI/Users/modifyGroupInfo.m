//
//  GetGroupInfoAPi.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-18.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "modifyGroupInfo.h"
#import "GroupEntity.h"
#import "IMGroup.pb.h"
#import "DDUserEntity.h"
@implementation ModifyGroupInfoApi
- (int)requestTimeOutTimeInterval
{
    return 3;
}

- (int)requestServiceID
{
    return SERVICE_GROUP;
}

- (int)responseServiceID
{
    return SERVICE_GROUP;
}

- (int)requestCommendID
{
    return GroupCmdIDCidGroupInfoChangeRequest;
}

- (int)responseCommendID
{
    return GroupCmdIDCidGroupInfoChangeRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMGroupNameChangeRsp * rsp = [IMGroupNameChangeRsp parseFromData:data];
        NSInteger code = rsp.code;
        return @(code);
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        IMGroupNameChangeReqBuilder* builder = [IMGroupNameChangeReq builder ];
        [builder setUserId:0];
        NSString* localgid = object[0] ;
        uint32_t type   = [object[1] integerValue];;
        NSString* nvalue = object[2] ;
        
        NSInteger gid = [GroupEntity localGroupIDTopb:localgid];
        [builder setChangeType:type];
        [builder setGroupId:gid];
        [builder setValue:nvalue];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:[self requestServiceID]
                                    cId:[self requestCommendID]
                                  seqNo:seqNo];
        [dataout directWriteBytes:[builder build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];

    };
    return package;
}
@end
