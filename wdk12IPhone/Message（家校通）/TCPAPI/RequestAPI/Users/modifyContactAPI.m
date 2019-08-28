//
//  GetGroupInfoAPi.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-18.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "modifyContactAPI.h"
#import "GroupEntity.h"
#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
@implementation ModifyContactApi
- (int)requestTimeOutTimeInterval
{
    return 3;
}

- (int)requestServiceID
{
    return MODULE_ID_SESSION;
}

- (int)responseServiceID
{
    return MODULE_ID_SESSION;
}

- (int)requestCommendID
{
    return BuddyListCmdIDCidModifyContactRequest;
}

- (int)responseCommendID
{
    return BuddyListCmdIDCidModifyContactRespone;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMModifyContactRsp *rsp = [IMModifyContactRsp parseFromData:data];
        
        NSInteger code = rsp.resultCode;

        return @(code);
       
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        IMModifyContactReqBuilder* builder = [IMModifyContactReq builder ];
        [builder setUserId:0];
        NSInteger ttype = [object[0] integerValue];
        NSInteger tid   = 0;
        NSInteger opt = [object[2] integerValue];
        if(ttype == 1) tid = [DDUserEntity localIDTopb:object[1]];
        if(ttype == 2) tid = [GroupEntity localGroupIDTopb:object[1]];
        
        [builder setTargetid:tid];
        [builder setTargettype:ttype];
        [builder setOpt:opt];
        
        
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
