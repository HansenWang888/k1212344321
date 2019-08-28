//
//  DDMessageEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDMessageEntity.h"
#import "DDUserModule.h"

#import "Encapsulator.h"
#import "DDMessageModule.h"
#import "DDDataInputStream.h"
#import "RuntimeStatus.h"
#import "IMMessage.pb.h"

#import "security.h"

@implementation DDMessageEntity
+(DDMessageContentType)msgTypeToConentType:(MsgType) msgtype{
    return  DDMessageContentType(msgtype&0xf);
}
+(SessionType)getSesstionTypeByMsgType:(MsgType) msgtype{
    if(msgtype&0x100) return SessionTypeSessionTypeSubscription;
    if(msgtype&0x10)  return SessionTypeSessionTypeGroup;
    return SessionTypeSessionTypeSingle;
}
- (DDMessageEntity*)initWithMsgID:(NSUInteger )ID msgType:(MsgType)msgType msgTime:(double)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID
{
    self = [super init];
    if (self)
    {
        _msgID = ID;
        _msgType = msgType;
        _msgTime = msgTime;
        _sessionId = [sessionID copy];
        _senderId = [senderID copy];
        _msgContent =msgContent;
        _toUserID = [toUserID copy];
        _info = [[NSMutableDictionary alloc] init];
        _msgContentType = [DDMessageEntity msgTypeToConentType:_msgType];
        _sessionType = [DDMessageEntity getSesstionTypeByMsgType:_msgType];
        _state = DDMessageSending;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    DDMessageEntity *ddmentity =[[[self class] allocWithZone:zone] initWithMsgID:_msgID msgType:_msgType msgTime:_msgTime sessionID:_sessionId senderID:_senderId msgContent:_msgContent toUserID:_toUserID];
    return ddmentity;
}

#pragma mark -
#pragma mark - privateAPI
- (NSString*)getNewMessageContentFromContent:(NSString*)content
{
    
    NSMutableString *msgContent = [NSMutableString stringWithString:content?content:@""];
    NSMutableString *resultContent = [NSMutableString string];
    NSRange startRange;
    // NSDictionary* emotionDic = [EmotionsModule shareInstance].emotionUnicodeDic;
    while ((startRange = [msgContent rangeOfString:@"["]).location != NSNotFound) {
        if (startRange.location > 0)
        {
            NSString *str = [msgContent substringWithRange:NSMakeRange(0, startRange.location)];
            //   WDULog(@"[前文本内容:%@",str);
            [msgContent deleteCharactersInRange:NSMakeRange(0, startRange.location)];
            startRange.location=0;
            [resultContent appendString:str];
        }
        
        NSRange endRange = [msgContent rangeOfString:@"]"];
        if (endRange.location != NSNotFound) {
            NSRange range;
            range.location = 0;
            range.length = endRange.location + endRange.length;
            NSString *emotionText = [msgContent substringWithRange:range];
            [msgContent deleteCharactersInRange:
             NSMakeRange(0, endRange.location + endRange.length)];
            
            //    WDULog(@"类似表情字串:%@",emotionText);
            //            NSString *emotion = emotionDic[emotionText];
            //            if (emotion) {
            //                // 表情
            //                [resultContent appendString:emotion];
            //            } else
            //            {
            //                [resultContent appendString:emotionText];
            //            }
        } else {
            //  WDULog(@"没有[匹配的后缀");
            break;
        }
    }
    
    if ([msgContent length] > 0)
    {
        [resultContent appendString:msgContent];
    }
    return resultContent;
}

-(BOOL)isGroupMessage
{
    //    if (self.msgType == MsgTypeMsgTypeGroupAudio || self.msgType == MsgTypeMsgTypeGroupText) {
    //        return YES;
    //    }
    //
    //    return NO;
    //   if(self.msgType)
    if(self.msgType & 0x10){
        return YES;
    }
    else{
        return NO;
    }
}

-(SessionType)getMessageSessionType
{
    return (![self isGroupMessage]?SessionTypeSessionTypeSingle:SessionTypeSessionTypeGroup);
}

-(BOOL)isGroupVoiceMessage
{
    if (self.msgType == MsgTypeMsgTypeGroupAudio) {
        return YES;
    }
    return NO;
}
-(BOOL)isVoiceMessage
{
    
    return self.msgContentType == DDMessageTypeVoice;
}
-(BOOL)isImageMessage
{
    return self.msgContentType == DDMessageTypeImage;
}
-(BOOL)isSendBySelf
{
    if ([self.senderId isEqualToString:TheRuntime.user.objID]) {
        return YES;
    }
    return NO;
}
-(void)fillMsgInfo{
    if(self.msgContentType != DDMessageTypeImage && self.msgContentType != DDMessageTypeVoice && self.msgContentType != DDMessageTypeRichText && self.msgContentType != DDMessageTypeDoc&&self.msgContentType != DDMessageTypeInvite && self.msgContentType != DDMessageTypeShare) return;
    NSData* data = [self.msgContent dataUsingEncoding:NSUTF8StringEncoding];
    if(!data) {
        NSLog(@"消息数据为空");
        return;
    }
    NSError* jsonerror = nil;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
    if(jsonerror){
        NSLog(@"消息JSON解析失败");
        return;
    }
    [self.info setValuesForKeysWithDictionary:dic];
    
}
+(DDMessageEntity *)makeMessageFromPB:(MsgInfo *)info SessionType:(SessionType)sessionType
{
    DDMessageEntity *msg = [DDMessageEntity new];
    
    msg.msgType=info.msgType;
    NSMutableDictionary* msgInfo = [[NSMutableDictionary alloc] init];
    
    
    msg.msgContent = [DDMessageEntity getMD5msg:info.msgData];
    msg.msgContentType = (DDMessageContentType)(msg.msgType&0x0f);
    
    msg.sessionId=[TheRuntime changeOriginalToLocalID:info.fromSessionId SessionType:sessionType];
    msg.msgID=info.msgId;
    msg.toUserID =TheRuntime.user.objID;
    if(sessionType == SessionTypeSessionTypeSubscription){
        msg.senderId=[TheRuntime changeOriginalToLocalID:info.fromSessionId SessionType:SessionTypeSessionTypeSubscription];
    }
    else{
        msg.senderId=[TheRuntime changeOriginalToLocalID:info.fromSessionId SessionType:SessionTypeSessionTypeSingle];
    }
    msg.msgTime = info.createTime;
    msg.info=msgInfo;
    [msg fillMsgInfo];
    
    return msg;
}
+(NSString*)getMD5msg:(NSData*) indata{
    
    
    
    
    __block  NSString* ret = nil;
    
    NSString *tmpStr =[[NSString alloc] initWithData:indata encoding:NSUTF8StringEncoding];
    
    
    char* pOut;
    uint32_t nOutLen;
    
    
    __strong const char* tmp = [tmpStr cStringUsingEncoding:NSUTF8StringEncoding];
    
    if(!tmp){
        return @"";
    }
    
    uint32_t nInLen = strlen(tmp);
    int nRet = DecryptMsg(tmp, nInLen, &pOut, nOutLen);
    
    if (nRet == 0) {
        ret =[NSString stringWithCString:pOut encoding:NSUTF8StringEncoding];
        //            if ([msg.msgContent hasPrefix:DD_MESSAGE_IMAGE_PREFIX])
        //            {
        //                msg.msgContentType = DDMessageTypeImage;
        //            }
        Free(pOut);
    }else{
        ret = @"";
    }
    
    if(ret == nil) ret = @"";
    
    return ret;
}
+(NSData *)hexStringToData:(NSString *)string
{
    NSString *command = string;
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}
+(DDMessageEntity *)makeMessageFromPBData:(IMMsgData *)data
{
    DDMessageEntity *msg = [DDMessageEntity new];
    msg.msgType=data.msgType;
    
    SessionType type = [DDMessageEntity getSesstionTypeByMsgType:msg.msgType];
    msg.sessionType=type;
    NSMutableDictionary* msgInfo = [[NSMutableDictionary alloc] init];
    
    
    msg.msgContent = [DDMessageEntity getMD5msg:data.msgData];
    msg.msgContentType = (DDMessageContentType)(msg.msgType&0x0f);
    
    if (msg.sessionType == SessionTypeSessionTypeSingle|| msg.sessionType == SessionTypeSessionTypeSubscription) {
        msg.sessionId=[TheRuntime changeOriginalToLocalID:data.fromUserId SessionType:type];
    }else if(msg.sessionType == SessionTypeSessionTypeGroup){
        msg.sessionId=[TheRuntime changeOriginalToLocalID:data.toSessionId SessionType:type];
    }
    
    msg.msgID=data.msgId;
    msg.toUserID =msg.sessionId;
    if (msg.sessionType == SessionTypeSessionTypeSubscription) {
        msg.senderId=[TheRuntime changeOriginalToLocalID:data.fromUserId SessionType:SessionTypeSessionTypeSubscription];
    }
    else{
        msg.senderId=[TheRuntime changeOriginalToLocalID:data.fromUserId SessionType:SessionTypeSessionTypeSingle];
        
        if ([msg.senderId isEqual:TheRuntime.user.objID]) {
            msg.sessionId=[TheRuntime changeOriginalToLocalID:data.toSessionId SessionType:type];
        }
    }
    msg.msgTime=[NSDate date].timeIntervalSince1970;
    msg.info=msgInfo;
    [msg fillMsgInfo];
    return msg;
}


@end
@implementation DDTimeDimMessageEntity
-(id)initWithTimeInterval:(NSTimeInterval)time{
    self = [super init];
    self.msgTime = time;
    self.msgContentType = DDMessageTypeTimeDim;
    self.msgID = -1;
    return self;
}
@end
