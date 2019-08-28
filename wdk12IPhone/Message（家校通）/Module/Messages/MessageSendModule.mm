#import "MessageSendModule.h"
#import "DDDatabaseUtil.h"
#import "security.h"
#import "SendMessageAPI.h"
#import "SDWebImageManager.h"
#import "fileModule.h"
#import "SessionModule.h"
#import "UIImage+FullScreen.h"
static uint32_t seqNo = 0;
@implementation MessageSendModule
{
    dispatch_semaphore_t _sendChannel;
    dispatch_queue_t     _sendQueue;
    
    NSMutableIndexSet*   _inqueueMessageIds;
    //暂时无用
    NSMutableArray*      _inqueueMessages;
}
+(MessageSendModule*)shareInstance{
    static MessageSendModule* g_MessageSendModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_MessageSendModule = [[MessageSendModule alloc] init];
    });
    return g_MessageSendModule;
}
+ (NSUInteger )getMessageID
{
    NSInteger messageID = [[NSUserDefaults standardUserDefaults] integerForKey:@"msg_id"];
    if(messageID == 0)
    {
        messageID=LOCAL_MSG_BEGIN_ID;
    }else{
        messageID ++;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:messageID forKey:@"msg_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return messageID;
}
-(id)init{
    self = [super init];
    _sendChannel = dispatch_semaphore_create(1);
    _sendQueue = dispatch_queue_create("com.messagesending.jstx", DISPATCH_QUEUE_SERIAL);
    
    _inqueueMessageIds = [NSMutableIndexSet new];
    _inqueueMessages   = [NSMutableArray new];
    return self;
}

-(BOOL)isInSendingQueue:(DDMessageEntity*)msgentity{
    return [_inqueueMessageIds containsIndex:msgentity.msgID];
}

-(DDMessageEntity*)createMessageBySession:(SessionEntity*)sentity WithMessageType:(DDMessageContentType)msgtype Content:(NSString*)content{
    
    MsgType type =  (MsgType)msgtype;
    
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        type =  (MsgType)((msgtype&0xf)|0x10);
    }
    if(sentity.sessionType == SessionTypeSessionTypeSubscription){
        type = (MsgType)((msgtype&0xf)|0x100);
    }
    
    DDMessageEntity* msgentity = [[DDMessageEntity alloc]initWithMsgID:[MessageSendModule getMessageID] msgType:type msgTime:[[NSDate date] timeIntervalSince1970] sessionID:sentity.sessionID senderID:TheRuntime.user.objID msgContent:content toUserID:sentity.sessionID];
    
    return msgentity;
}
-(DDMessageEntity*)sendTextMessage:(NSString*)message Session:(SessionEntity*)sentity{
    

    
    NSString* parten = @"\\s";
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    NSString* checkoutText = [reg stringByReplacingMatchesInString:message options:NSMatchingReportProgress range:NSMakeRange(0, [message length]) withTemplate:@""];
    if ([checkoutText length] == 0)
    {
        NSLog(@"文本有点问题");
        return  nil;
    }
    
    DDMessageEntity* ret = [self createMessageBySession:sentity WithMessageType:DDMessageTypeText Content:checkoutText];

    [self messageInqueue:ret Session:sentity];
    return ret;

}
-(void)makeSubscribeMessage:(NSDictionary*)message Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    [self makeSubscribeMessageImpl:message Session:sentity Block:^(DDMessageEntity *msgentity) {
        if(msgentity){
            msgentity.state = DDmessageSendSuccess;
            [[DDDatabaseUtil instance]insertMessages:@[msgentity] success:^{
                
            } failure:^(NSString *errorDescripe) {
                
            }];
            [[SessionModule sharedInstance]updateSessionByMessage:sentity Message:msgentity];
        }
        block(msgentity);
    }];
}
-(void)makeSubscribeMessageImpl:(NSDictionary*)message Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    NSInteger mattype = [[message objectForKey:@"contenttype"] integerValue];
    if(mattype == 3){
        NSDictionary* mate = [message objectForKey:@"mate"];
        [self makeRichTextMessage:mate Session:sentity Block:block];
        return;
    }
    
    if(mattype == 2){
        NSString* url = [message objectForKey:@"httpurl"];
        [self makeSubscribeImageMessage:url Session:sentity Block:block];
        return;
    }

    if(mattype == 1){
        NSString* text = [message objectForKey:@"text"];
        [self makeSubscribeTextMessage:text Session:sentity Block:block];
        return;
    }
    if(mattype == 6){
        [self makeSubscribeFileMessageDict:message Session:sentity Block:block];
        return;
    }
    block(nil);
}
-(void)makeRichTextMessage:(NSDictionary*)message Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
        if(data == nil) block(nil);
        NSString* content = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DDMessageEntity* ret = [self createMessageBySession:sentity WithMessageType:DDMessageTypeRichText Content:content];
        ret.info = [NSMutableDictionary dictionaryWithDictionary:message];
        //这个消息是本地消息并不会发送，呵呵
        ret.senderId = sentity.sessionID;
        ret.toUserID = [TheRuntime user].objID;
        block(ret);
    });
}
-(void)makeSubscribeImageMessage:(NSString*)url Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    DDMessageEntity* imagemsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeImage Content:@""];
    
    [imagemsg.info setObject:[NSString stringWithFormat:@"%@",url] forKey:IMAGE_HTTP_KEY];

    NSError* jsonerror;
    NSData* data = [NSJSONSerialization dataWithJSONObject:imagemsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
    imagemsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    imagemsg.senderId = sentity.sessionID;
    imagemsg.toUserID = [TheRuntime user].objID;
    block(imagemsg);
}
-(void)makeSubscribeVideoMessage:(NSString*)url Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    DDMessageEntity* videomsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeVideo Content:@""];
    
    [videomsg.info setObject:[NSString stringWithFormat:@"%@",url] forKey:IMAGE_HTTP_KEY];
    
    NSError* jsonerror;
    NSData* data = [NSJSONSerialization dataWithJSONObject:videomsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
    videomsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    videomsg.senderId = sentity.sessionID;
    videomsg.toUserID = [TheRuntime user].objID;
    block(videomsg);
}
-(void)makeSubscribeVoiceMessage:(NSString*)url Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    DDMessageEntity* voicemsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeVoice Content:@""];
    
    [voicemsg.info setObject:[NSString stringWithFormat:@"%@",url] forKey:IMAGE_HTTP_KEY];
    [voicemsg.info setObject:@(10) forKey:VOICE_LENGTH_KEY];
    NSError* jsonerror;
    NSData* data = [NSJSONSerialization dataWithJSONObject:voicemsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
    voicemsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    voicemsg.senderId = sentity.sessionID;
    voicemsg.toUserID = [TheRuntime user].objID;
    block(voicemsg);
}
-(void)makeSubscribeFileMessageDict:(NSDictionary *)messageD Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    DDMessageEntity* filemsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeDoc Content:@""];
    
    [filemsg.info setObject:[NSString stringWithFormat:@"%@",messageD[FILE_ORIGIN_KEY]] forKey:FILE_ORIGIN_KEY];
    [filemsg.info setObject:[NSString stringWithFormat:@"%@",messageD[FILE_TRANS_KEY]] forKey:FILE_TRANS_KEY];
    [filemsg.info setObject:[NSString stringWithFormat:@"%@",messageD[FILE_NAME_KEY]] forKey:FILE_NAME_KEY];
    [filemsg.info setObject:[NSString stringWithFormat:@"%@",messageD[FILE_FILE_SIZE]] forKey:FILE_FILE_SIZE];

    NSError* jsonerror;
    NSData* data = [NSJSONSerialization dataWithJSONObject:filemsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
    filemsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    filemsg.senderId = sentity.sessionID;
    filemsg.toUserID = [TheRuntime user].objID;
    block(filemsg);
}
-(void)makeSubscribeTextMessage:(NSString*)text Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    DDMessageEntity* textmsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeText Content:text];
    

    textmsg.senderId = sentity.sessionID;
    textmsg.toUserID = [TheRuntime user].objID;
    block(textmsg);
}
-(void)sendImageMessage:(UIImage*)image  Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    
        
    NSURL *url =[NSURL URLWithString: [NSString stringWithFormat:@"%@.jpg",[[NSUUID UUID] UUIDString]]];
    
    [self sendImageMessageWithUrl:image Url:url Session:sentity Block:^(DDMessageEntity *msgentity) {
        block(msgentity);
    }];
}

-(void)sendImageMessageWithUrl:(UIImage*)image Url:(NSURL*)url Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imagedataData = UIImageJPEGRepresentation(image, 0);
        UIImage* compressimage = [UIImage imageWithData:imagedataData];
        
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        if(![manager diskImageExistsForURL:url] && ![manager cachedImageExistsForURL:url]){

            [manager saveImageToCache:compressimage forURL:url];
            
            UIImage* absimage = [UIImage imageWithImage:compressimage scaledToSize:CGSizeMake(110, 140)];
            
            NSURL* absurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@_abs",url]];
            [manager saveImageToCache:absimage forURL:absurl];
        }
        DDMessageEntity* imagemsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeImage Content:@""];
        
        [imagemsg.info setObject:[NSString stringWithFormat:@"%@",url] forKey:IMAGE_LOCAL_KEY];
        NSError* jsonerror;
        NSData* data = [NSJSONSerialization dataWithJSONObject:imagemsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
        imagemsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(imagemsg);
        });
        
        [self messageInqueue:imagemsg Session:sentity];
    });

}

-(void)sendVoiceWithFilePath:(NSString*)filepath Length:(NSTimeInterval)length Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DDMessageEntity* voicemsg = [self createMessageBySession:sentity WithMessageType:DDMessageTypeVoice Content:@""];
        
        NSString* filename = [filepath lastPathComponent];
        
        [voicemsg.info setObject:filename forKey:VOICE_LOCAL_KEY];
        [voicemsg.info setObject:@(length) forKey:VOICE_LENGTH_KEY];
        NSError* jsonerror;
        NSData* data = [NSJSONSerialization dataWithJSONObject:voicemsg.info options:NSJSONWritingPrettyPrinted error:&jsonerror];
        voicemsg.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(voicemsg);
            
        });
        
        [self messageInqueue:voicemsg Session:sentity];
    });
}

-(void)sendSubscribeInviteMessageToUser:(NSString*)uid SBID:(NSString*)sbid{
    SessionEntity* sentity = [[SessionModule sharedInstance]GetOrCreateSessionEntityWithUserID:uid];

    [self sendSubscribeInviteMessageToSession:sentity SBID:sbid];
    
}
-(void)sendSubscribeInviteMessageToGroup:(NSString*)gid SBID:(NSString*)sbid{
    SessionEntity* sentity = [[SessionModule sharedInstance]GetOrCreateSessionEntityWithGroupID:gid];
    [self sendSubscribeInviteMessageToSession:sentity SBID:sbid];
}
-(void)sendSubscribeInviteMessageToSession:(SessionEntity*)sentity SBID:(NSString*)sbid{
    
    NSDictionary* info =  @{@"inviter":  @([TheRuntime changeIDToOriginal:TheRuntime.user.objID]),
                            @"invitee":@([TheRuntime changeIDToOriginal:sentity.sessionID]),
                            @"inviteeType":@(sentity.sessionType),
                            @"target":@([TheRuntime changeIDToOriginal:sbid]),
                            @"targetType":@(SessionTypeSessionTypeSubscription)};
    NSData* infodata = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    NSString* content = [[NSString alloc]initWithData:infodata encoding:NSUTF8StringEncoding];
    DDMessageEntity* msgEntity = [self createMessageBySession:sentity WithMessageType:DDMessageTypeInvite Content:content];
    msgEntity.info = [[NSMutableDictionary alloc]initWithDictionary:info];
    
    [self messageInqueue:msgEntity Session:sentity];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReceiveMessage object:@[msgEntity]];
    });
}
-(void)resendMessage:(DDMessageEntity*)msgentity Session:(SessionEntity*)sentity{
    [self messageInqueue:msgentity Session:sentity];
}

-(void)messageInqueue:(DDMessageEntity*)msgentity Session:(SessionEntity*)sentity{
    if([_inqueueMessageIds containsIndex:msgentity.msgID]) return;
    
    [[DDDatabaseUtil instance]insertMessages:@[msgentity] success:^{
        
    } failure:^(NSString *errorDescripe) {
        NSLog(@"丢失消息，发送失败则不存在了");
    }];
    [_inqueueMessageIds addIndex:msgentity.msgID];
    [[SessionModule sharedInstance] updateSessionByMessage:sentity Message:msgentity];

    //to notify session update
    
    dispatch_async(_sendQueue, ^{
        dispatch_semaphore_wait(_sendChannel, DISPATCH_TIME_FOREVER);
        //上传失败就滚蛋
        if(![self makeSureMessageSendable:msgentity]){
            msgentity.state = DDMessageSendFailure;
            [[DDDatabaseUtil instance]insertMessages:@[msgentity] success:^{
                
            } failure:^(NSString *errorDescripe) {
                
            }];
            [_inqueueMessageIds removeIndex:msgentity.msgID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationMessageSendingStateChanged object:@[msgentity.sessionId, @(DDMessageSendFailure),@(msgentity.msgID),@(msgentity.msgID)]];
            });

            
            dispatch_semaphore_signal(_sendChannel);
            return ;
        }
        
        SendMessageAPI* sendMessageAPI = [[SendMessageAPI alloc] init];
        uint32_t nowSeqNo = ++seqNo;
        msgentity.seqNo=nowSeqNo;
        
     //   NSLog(@"send message to server:%@",msgentity.msgContent);
        NSString* newContent = msgentity.msgContent;
        char* pOut;
        uint32_t nOutLen;
        const char *test =[newContent cStringUsingEncoding:NSUTF8StringEncoding];
        uint32_t nInLen  = strlen(test);
        EncryptMsg(test, nInLen, &pOut, nOutLen);
        
        
        NSData *data = [[NSString stringWithCString:pOut encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        Free(pOut);
        NSArray* object = @[TheRuntime.user.objID,msgentity.sessionId,data,@(msgentity.msgType),@(msgentity.msgID)];
        

        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                NSInteger oldmsgid = msgentity.msgID;
                [_inqueueMessageIds removeIndex:oldmsgid];
                dispatch_semaphore_signal(_sendChannel);
                

                //NSLog(@"发送消息成功");
                [[DDDatabaseUtil instance] deleteMesages:msgentity completion:^(BOOL success){
                    
                }];
                msgentity.msgID=[response[0] integerValue];
                msgentity.state=DDmessageSendSuccess;
                
                
                [[DDDatabaseUtil instance] insertMessages:@[msgentity] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationMessageSendingStateChanged object:@[msgentity.sessionId, @(DDmessageSendSuccess),@(oldmsgid),@(msgentity.msgID)]];
                });

                
                [[SessionModule sharedInstance] updateSessionByMessage:sentity Message:msgentity];
                [[SessionModule sharedInstance] setSessionRead:sentity];
            }
            else
            {
                [_inqueueMessageIds removeIndex:msgentity.msgID];
                dispatch_semaphore_signal(_sendChannel);
                msgentity.state=DDMessageSendFailure;
                [[DDDatabaseUtil instance] insertMessages:@[msgentity] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
               dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationMessageSendingStateChanged object:@[msgentity.sessionId, @(DDMessageSendFailure),@(msgentity.msgID),@(msgentity.msgID)]]; 
               });

            }
        }];
    });

}
-(BOOL)makeSureMessageSendable:(DDMessageEntity*)msgentity{
    //文字消息不阻塞
    if((msgentity.msgType & 0x0f) == MsgTypeMsgTypeSingleText) return YES;
    else if((msgentity.msgType & 0x0f) == MsgTypeMsgTypeSingleImage) {
        return [self makeSureImageSendable:msgentity];
    }
    else if ((msgentity.msgType & 0x0f) == MsgTypeMsgTypeSingleAudio){
        return [self makeSureVoiceSendable:msgentity];
    }
    else if((msgentity.msgContentType == DDMessageTypeInvite)) return YES;
    else return NO;
}
-(BOOL)makeSureImageSendable:(DDMessageEntity*)msgentity{
    NSString* local = [msgentity.info objectForKey:IMAGE_LOCAL_KEY];
    NSString* httpurl = [msgentity.info objectForKey:IMAGE_HTTP_KEY];
    
    
    
    if(httpurl) return YES;
    
    
    UIImage* image = nil;
    do{
        if(!local) break;
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        NSString* key = [manager cacheKeyForURL:[NSURL URLWithString:local]];
        
        image = [manager.imageCache imageFromMemoryCacheForKey:key];
        
        if(!image) image = [manager.imageCache imageFromDiskCacheForKey:key];
        
        if(!image) {
            break;
        }
        
        
    }while (0);
    
    if(!image){
        //准备删除消息
        return NO;
    }
    
    dispatch_semaphore_t sig_upload =  dispatch_semaphore_create(0);
    
    NSLog(@"%@",[local lastPathComponent]);
    
    __block BOOL returnv = NO;
    [[FileModule shareInstance]uploadImage:image Name:local Block:^(NSError *error, NSString * fileid) {
        
        if(!error){

            NSDictionary* dic = @{IMAGE_HTTP_KEY:fileid};
            NSError* jsonserror = nil;
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&jsonserror];
            
            if(!jsonserror){
                [msgentity.info setObject:fileid forKey:IMAGE_HTTP_KEY];
                msgentity.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [[DDDatabaseUtil instance]insertMessages:@[msgentity] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                
                returnv = YES;
            }
            else{
                NSLog(@"json序列化失败");
            }
        }
        else{
            NSLog(@"上传失败");
        }
        
        dispatch_semaphore_signal(sig_upload);
    }];
    
    dispatch_semaphore_wait(sig_upload, DISPATCH_TIME_FOREVER);
    
    
    return returnv;
}
-(BOOL)makeSureVoiceSendable:(DDMessageEntity*)msgentity{
    NSString* localfilename = [msgentity.info objectForKey: VOICE_LOCAL_KEY];
    NSString* httpurl = [msgentity.info objectForKey:VOICE_HTTP_KEY];
    NSTimeInterval length = [[msgentity.info objectForKey:VOICE_LENGTH_KEY] doubleValue];
    
    if(httpurl) return YES;
    
    NSString* local = [[FileModule shareInstance]getLocalVoiceFilePath:localfilename];
    NSData* data = [NSData dataWithContentsOfFile:local];
    
    if(!data) return NO;
    
    dispatch_semaphore_t sig_upload =  dispatch_semaphore_create(0);
    
    __block BOOL retv = NO;
    [[FileModule shareInstance]uploadAudio:data Name:local Block:^(NSError * error, NSString * fileid) {
        if(!error){
            NSDictionary* dic = @{VOICE_HTTP_KEY:fileid,VOICE_LENGTH_KEY:@(length)};
            NSError* jsonserror = nil;
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&jsonserror];
            
            if(!jsonserror){
                [msgentity.info setObject:fileid forKey:VOICE_HTTP_KEY];
                msgentity.msgContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [[DDDatabaseUtil instance]insertMessages:@[msgentity] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                
                retv = YES;
            }
            else{
                NSLog(@"json序列化失败");
            }
        }
        else{
            NSLog(@"上传失败");
        }
        
        dispatch_semaphore_signal(sig_upload);
    }];
    
    dispatch_semaphore_wait(sig_upload, DISPATCH_TIME_FOREVER);
    
    return retv;
}
@end
