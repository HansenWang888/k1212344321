//
//  DDSendMessageAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "SendMessageAPI.h"
#import "IMMessage.pb.h"
@implementation SendMessageAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 10;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return DDCMD_MSG_DATA;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_MSG_RECEIVE_DATA_ACK;
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
        IMMsgDataAck *msgDataAck = [IMMsgDataAck parseFromData:data];
        return @[@(msgDataAck.msgId),@(msgDataAck.sessionId)];
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
        NSString* fromId = array[0];
        NSString* toId = array[1];
        NSData* content = array[2];
        MsgType type = [array[3] intValue];
        IMMsgDataBuilder *msgdata = [IMMsgData builder];
        [msgdata setFromUserId:0];
        [msgdata setToSessionId:[TheRuntime changeIDToOriginal:toId]];
        [msgdata setMsgData:content];
        [msgdata setMsgType:type];
        [msgdata setMsgId:0];
        [msgdata setCreateTime:0];
        [msgdata setSenderLastetUpdated:TheRuntime.user.lastUpdateTime];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE cId:DDCMD_MSG_DATA seqNo:seqNo];
        [dataout directWriteBytes:[msgdata build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];

    };
    return package;
}

@end
