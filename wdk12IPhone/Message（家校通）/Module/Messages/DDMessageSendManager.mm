
//
//  DDMessageSendManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageSendManager.h"
#import "DDUserModule.h"
#import "DDMessageEntity.h"
#import "DDMessageModule.h"
#import "DDTcpClientManager.h"
#import "SendMessageAPI.h"
#import "RuntimeStatus.h"
//#import "RecentUsersViewController.h"

#import "NSDictionary+JSON.h"
#import "UnAckMessageManager.h"
#import "DDGroupModule.h"
#import "DDClientState.h"
#import "NSData+Conversion.h"
#import "DDDatabaseUtil.h"
#import "security.h"
#import "SessionModule.h"
static uint32_t seqNo = 0;

@interface DDMessageSendManager(PrivateAPI)

- (NSString* )toSendmessageContentFromContent:(NSString*)content;

@end

@implementation DDMessageSendManager
{
    NSUInteger _uploadImageCount;
}
+ (instancetype)instance
{
    static DDMessageSendManager* g_messageSendManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageSendManager = [[DDMessageSendManager alloc] init];
    });
    return g_messageSendManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _uploadImageCount = 0;
        _waitToSendMessage = [[NSMutableArray alloc] init];
        _sendMessageSendQueue = dispatch_queue_create("com.mogujie.Duoduo.sendMessageSend", NULL);
        
    }
    return self;
}

- (void)sendMessage:(DDMessageEntity *)message isGroup:(BOOL)isGroup Session:(SessionEntity*)session completion:(DDSendMessageCompletion)completion Error:(void (^)(NSError *))block
{
    

    
    dispatch_async(self.sendMessageSendQueue, ^{
        SendMessageAPI* sendMessageAPI = [[SendMessageAPI alloc] init];
        uint32_t nowSeqNo = ++seqNo;
        message.seqNo=nowSeqNo;
   
        NSLog(@"send message to server:%@",message.msgContent);
        NSString* newContent = message.msgContent;
//        if ([message isImageMessage]) {
//            NSDictionary* dic = [NSDictionary initWithJsonString:message.msgContent];
//            NSString* urlPath = dic[DD_IMAGE_URL_KEY];
//            newContent=urlPath;
//        }
        
        char* pOut;
        uint32_t nOutLen;
        const char *test =[newContent cStringUsingEncoding:NSUTF8StringEncoding];
        uint32_t nInLen  = strlen(test);
        EncryptMsg(test, nInLen, &pOut, nOutLen);
        

        NSData *data = [[NSString stringWithCString:pOut encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        Free(pOut);
        NSArray* object = @[TheRuntime.user.objID,session.sessionID,data,@(message.msgType),@(message.msgID)];

        [[UnAckMessageManager instance] addMessageToUnAckQueue:message];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:session];
        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                    NSLog(@"发送消息成功");
                    [[DDDatabaseUtil instance] deleteMesages:message completion:^(BOOL success){
                       
                    }];
                
                    [[UnAckMessageManager instance] removeMessageFromUnAckQueue:message];
                    message.msgID=[response[0] integerValue];
                    message.state=DDmessageSendSuccess;
                    session.lastMsgID=message.msgID;


                

                     [[DDDatabaseUtil instance] insertMessages:@[message] success:^{
                         
                     } failure:^(NSString *errorDescripe) {
                         
                     }];
                    completion(message,nil);
            }
            else
            {
                message.state=DDMessageSendFailure;
                [[DDDatabaseUtil instance] insertMessages:@[message] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                NSError* error = [NSError errorWithDomain:IMLocalizedString(@"发送消息失败", nil) code:0 userInfo:nil];
                block(error);
            }
        }];
        
    });
}

- (void)sendVoiceMessage:(NSData*)voice filePath:(NSString*)filePath forSessionID:(NSString*)sessionID isGroup:(BOOL)isGroup Message:(DDMessageEntity *)msg Session:(SessionEntity*)session completion:(DDSendMessageCompletion)completion
{
    dispatch_async(self.sendMessageSendQueue, ^{
        SendMessageAPI* sendVoiceMessageAPI = [[SendMessageAPI alloc] init];

        NSString* myUserID = [RuntimeStatus instance].user.objID;
        NSArray* object = @[myUserID,sessionID,voice,@(msg.msgType),@(0)];
        [sendVoiceMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
              
                
                NSLog(@"发送消息成功");
                [[DDDatabaseUtil instance] deleteMesages:msg completion:^(BOOL success){
                    
                }];
                
              
                NSUInteger messageTime = [[NSDate date] timeIntervalSince1970];
                msg.msgTime=messageTime;
                msg.msgID=[response[0] integerValue];
                msg.state=DDmessageSendSuccess;
                session.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"语音", nil)];
                session.lastMsgID=msg.msgID;
                session.timeInterval=msg.msgTime;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:session];
                [[DDDatabaseUtil instance] insertMessages:@[msg] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];

                    completion(msg,nil);
                
            }
            else
            {
                NSError* error = [NSError errorWithDomain:IMLocalizedString(@"发送消息失败", nil) code:0 userInfo:nil];
                completion(nil,error);
            }
        }];

    });
}

#pragma mark Private API



@end
