//
//  DDGetUserUnreadMessagesAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-12.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "GetUnreadMessagesAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "DDUserModule.h"
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
#import "SessionEntity.h"
#import "IMMessage.pb.h"
#import "IMBaseDefine.pb.h"
#import "GroupEntity.h"
#import "DDMessageEntity.h"
@implementation GetUnreadMessagesAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 20;
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
    return CID_MSG_UNREAD_CNT_REQUEST;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CID_MSG_UNREAD_CNT_RESPONSE;
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
        IMUnreadMsgCntRsp *unreadrsp = [IMUnreadMsgCntRsp parseFromData:data];
       
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSInteger m_total_cnt = unreadrsp.totalCnt;
        [dic setObject:@(m_total_cnt) forKey:@"m_total_cnt"];
         NSMutableArray *array = [NSMutableArray new];
        for (UnreadInfo *unreadInfo in unreadrsp.unreadinfoList) {
            NSString *userID = @"";
            NSInteger sessionType = unreadInfo.sessionType;
            userID = [TheRuntime changeOriginalToLocalID:unreadInfo.sessionId SessionType:sessionType];
            
            NSInteger unread_cnt = unreadInfo.unreadCnt;
            NSInteger latest_msg_id = unreadInfo.latestMsgId;
            NSInteger latest_msg_time = unreadInfo.latestMsgTime;
            
            SessionEntity *session = [[SessionEntity alloc] initWithSessionID:userID type:sessionType];
            session.unReadMsgCount=unread_cnt;

            DDMessageContentType msgtype = unreadInfo.latestMsgType&0xf;
            if(msgtype == DDMessageTypeImage){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"图片", nil)];
            }
            else if(msgtype == DDMessageTypeVoice){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"语音", nil)];
            }
            else if(msgtype == DDMessageTypeShare){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"分享", nil)];
            }
            else if(msgtype == DDMessageTypeDoc){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"文件", nil)];
            }
            else if(msgtype == DDMessageTypeRichText){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"图文", nil)];
            }
            else if(msgtype == DDMessageTypeVideo){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"视频", nil)];
            }
            else if(msgtype == DDMessageTypeInvite){
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"推荐公众号", nil)];
            } else if (msgtype == DDMessageTypeText) {
                session.lastMsg=[DDMessageEntity getMD5msg:unreadInfo.latestMsgData];
            }  else if (msgtype == DDMessageTypeShare) {
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"分享", nil)];
            } else{
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"未知消息类型", nil)];
            }

            session.lastMsgID=latest_msg_id;
            session.timeInterval = latest_msg_time;

            [array addObject:session];

        }
       
        [dic setObject:array forKey:@"sessions"];
        return dic;
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
        IMUnreadMsgCntReqBuilder *unreadreq = [IMUnreadMsgCntReq builder];
        [unreadreq setUserId:0];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:CID_MSG_UNREAD_CNT_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[unreadreq build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
