//
//  DDReceiveMessageAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDReceiveMessageAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
#import "IMMessage.pb.h"
@implementation DDReceiveMessageAPI
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

- (int)responseCommandID
{
    return DDCMD_MSG_DATA;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
      
        IMMsgData *msgdata = [IMMsgData parseFromData:data];
        DDMessageEntity *msg = [DDMessageEntity makeMessageFromPBData:msgdata];
       
        msg.state=DDmessageSendSuccess;
        
        NSInteger lasttime = msgdata.senderLastetUpdated;
        
        return @[msg,@(lasttime)];
    };
    return analysis;
}
@end
