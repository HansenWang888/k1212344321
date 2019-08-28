//
//  DDMessageEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChattingModule;
@class DDDataInputStream;
@class IMMsgData;
#import "IMBaseDefine.pb.h"
typedef NS_ENUM(NSUInteger, DDMessageType)
{
    MESSAGE_TYPE_SINGLE =1,                 //单个人会话消息
    MESSAGE_TYPE_TEMP_GROUP  =2,                     //临时群消息.
};
typedef NS_ENUM(NSUInteger, DDMessageContentType)
{
    DDMessageTypeText   =MsgTypeMsgTypeSingleText,
    DDMessageTypeImage  =MsgTypeMsgTypeSingleImage,
    DDMessageTypeVoice  =MsgTypeMsgTypeSingleAudio,
    DDMessageTypeShare  =MsgTypeMsgTypeSingleShare,
    DDMessageTypeLog = MsgTypeMsgTypeSingleLog,
    DDMessageTypeRichText = MsgTypeMsgTypeSingleRichtext,
    DDMessageTypeVideo = MsgTypeMsgTypeSingleVideo,
    DDMessageTypeDoc = MsgTypeMsgTypeSingleDoc,
    DDMessageTypeInvite = MsgTypeMsgTypeSingleInvite,
    DDMessageTypeTimeDim = 0xf0000000
};

typedef NS_ENUM(NSUInteger, DDMessageState)
{
    DDMessageSending =0,
    DDMessageSendFailure =1,
    DDmessageSendSuccess =2
};

//图片
#define DD_MESSAGE_IMAGE_PREFIX             @"&$#@~^@[{:"
#define DD_MESSAGE_IMAGE_SUFFIX             @":}]&$~@#@"

//语音
#define VOICE_LENGTH                        @"voiceLength"
#define DDVOICE_PLAYED                      @"voicePlayed"

//voice
#define DD_IMAGE_LOCAL_KEY                  @"local"
#define DD_IMAGE_URL_KEY                    @"url"

//商品
#define DD_COMMODITY_ORGPRICE               @"orgprice"
#define DD_COMMODITY_PICURL                 @"picUrl"
#define DD_COMMODITY_PRICE                  @"price"
#define DD_COMMODITY_TIMES                  @"times"
#define DD_COMMODITY_TITLE                  @"title"
#define DD_COMMODITY_URL                    @"URL"
#define DD_COMMODITY_ID                     @"CommodityID"




#define IMAGE_LOCAL_KEY                      @"local"
#define IMAGE_HTTP_KEY                       @"httpurl"

#define VOICE_LOCAL_KEY                      IMAGE_LOCAL_KEY
#define VOICE_HTTP_KEY                       IMAGE_HTTP_KEY
#define VOICE_LENGTH_KEY                     @"length"
#define FILE_NAME_KEY                        @"filename"
#define FILE_ORIGIN_KEY                     @"originurl"
#define FILE_TRANS_KEY                      @"transurl"
#define FILE_FILE_SIZE                      @"filesize"

@interface DDMessageEntity : NSObject
@property(assign) NSInteger  msgID;           //MessageID
@property(nonatomic,assign) MsgType msgType;              //消息类型
@property(nonatomic,assign) NSTimeInterval msgTime;             //消息收发时间
@property(nonatomic,strong) NSString* sessionId;        //会话id，
@property(assign)NSUInteger seqNo;
@property(nonatomic,strong) NSString* senderId;         //发送者的Id,群聊天表示发送者id
@property(nonatomic,strong) NSString* msgContent;       //消息内容,若为非文本消息则是json
@property(nonatomic,strong) NSString* toUserID;     //发消息的用户ID
@property(nonatomic,strong) NSMutableDictionary* info;     //一些附属的属性，包括语音时长
@property(assign)DDMessageContentType msgContentType;
@property(nonatomic,strong) NSString* attach;
@property(assign)SessionType sessionType;
//@property(nonatomic,assign) BOOL isSend;
@property(nonatomic,assign) DDMessageState state;       //消息发送状态
- (DDMessageEntity*)initWithMsgID:(NSUInteger )ID msgType:(MsgType)msgType msgTime:(NSTimeInterval)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID;

+(DDMessageContentType)msgTypeToConentType:(MsgType) msgtype;
+(SessionType)getSesstionTypeByMsgType:(MsgType) msgtype;


+(DDMessageEntity *)makeMessageFromStream:(DDDataInputStream *)bodyData;
-(BOOL)isGroupMessage;
-(SessionType)getMessageSessionType;
-(BOOL)isImageMessage;
-(BOOL)isVoiceMessage;
-(BOOL)isSendBySelf;

-(void)fillMsgInfo;

+(DDMessageEntity *)makeMessageFromPB:(MsgInfo *)info SessionType:(SessionType)sessionType;
+(DDMessageEntity *)makeMessageFromPBData:(IMMsgData *)data;
+(NSString*)getMD5msg:(NSData*) indata;
@end

@interface DDTimeDimMessageEntity : DDMessageEntity
-(id)initWithTimeInterval:(NSTimeInterval)time;
@end

