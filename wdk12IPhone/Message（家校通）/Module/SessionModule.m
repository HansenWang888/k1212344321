//
//  SessionModule.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-12-05.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "SessionModule.h"
#import "SessionEntity.h"
#import "NSDictionary+Safe.h"
#import "GetUnreadMessagesAPI.h"
#import "RemoveSessionAPI.h"
#import "DDDatabaseUtil.h"

#import "DDMessageEntity.h"
//#import "ChattingMainViewController.h"
#import "MsgReadNotify.h"
#import "MsgReadACKAPI.h"

#import "DDGroupModule.h"
#import "SubscribeModule.h"
#import "DDUserEntity.h"
#import "DDUserModule.h"
#import "ContactModule.h"
#import "DDMessageModule.h"
#import "DDClientState.h"
//#import "audiotoolbox/audioservices.h"
#import "audiotoolbox/audiotoolbox.h"
#import "DDReceiveMessageAPI.h"
#import "DDReceiveMessageACKAPI.h"
#import "DDMessageEntity.h"
#import "MsgReadACKAPI.h"
#import "DDGroupModule.h"
#import "GetMessageQueueAPI.h"
#import "ReportSessionApi.h"
@interface SessionModule()
@property(strong)NSMutableDictionary *sessions;
@property(strong)NSMutableDictionary *sessionState;
@end
@implementation SessionModule
DEF_SINGLETON(SessionModule)
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessions = [NSMutableDictionary new];
        self.sessionState = [NSMutableDictionary new];
    }
    [self regReciveMessage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSession) name:DDNotificationUserLoginSuccess object:nil];
    return self;
}

-(SessionEntity *)getSessionById:(NSString *)sessionID
{
    return [self.sessions safeObjectForKey:sessionID];
}
-(void)removeSessionById:(NSString *)sessionID
{
    [self.sessions removeObjectForKey:sessionID];
}
-(void)addToSessionModel:(SessionEntity *)session
{
    [self.sessions safeSetObject:session forKey:session.sessionID];
}
-(void)addSessionsToSessionModel:(NSArray *)sessionArray
{
    [sessionArray enumerateObjectsUsingBlock:^(SessionEntity *session, NSUInteger idx, BOOL *stop) {
        [self.sessions safeSetObject:session forKey:session.sessionID];
    }];
}


-(NSArray *)getAllSessions
{   
    return [self.sessions allValues];
}
-(void)removeSessionByServer:(SessionEntity *)session
{

    [self.sessions removeObjectForKey:session.sessionID];
    [[DDDatabaseUtil instance] removeSession:session.sessionID];
    RemoveSessionAPI *removeSession = [RemoveSessionAPI new];
    SessionType sessionType = session.sessionType;
    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionRemove object:session];
    if(session.sessionType == SessionTypeSessionTypeSubscription){
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeAbstractUpdate object:nil];
    }
    [removeSession requestWithObject:@[session.sessionID,@(sessionType)] Completion:^(id response, NSError *error) {
    }];

    
}
-(void)removeSessionLocal:(SessionEntity*)session{
    [self.sessions removeObjectForKey:session.sessionID];
    [[DDDatabaseUtil instance] removeSession:session.sessionID];
}
-(void)clearSession:(SessionEntity*)session{
    session.timeInterval = 0;
    session.unReadMsgCount = 0;
    session.lastMsgID = 0;
    session.lastMsg = @"";
    [[DDDatabaseUtil instance]updateRecentSession:session completion:^(NSError *error) {
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:session];
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeAbstractUpdate object:nil];

    });
}
-(void)loadLocalSession:(void(^)(bool isok))block
{
    [[DDDatabaseUtil instance] loadSessionsCompletion:^(NSArray *session, NSError *error) {
        [self addSessionsToSessionModel:session];

        block(YES);
        
    }];
}

-(void)setSessionOpened:(NSString*)sid Opened:(BOOL)opened{
    [_sessionState setObject:@(opened) forKey:sid];
}
-(BOOL)isSessionOpend:(NSString*)sid{
    return [[_sessionState objectForKey:sid]boolValue];
}
-(void)setSessionReadWithSessionID:(NSString*)sessionID{
    SessionEntity* sentity = [self getSessionById:sessionID];
    if(sentity) [self setSessionRead:sentity];
}
-(void)setSessionRead:(SessionEntity*)session{
    
//    if(session.unReadMsgCount == 0) return;
    session.unReadMsgCount = 0;
    MsgReadACKAPI* api = [MsgReadACKAPI new];
    [api requestWithObject:@[session.sessionID,@(session.lastMsgID),@(session.sessionType)] Completion:^(id response, NSError *error) {
        
    }];
    
    [[DDDatabaseUtil instance]updateRecentSession:session completion:^(NSError *error) {
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:session];
    });

}
-(NSInteger)getTopperSession{
    __block NSInteger toplevel = 0;
    [_sessions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, SessionEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        toplevel = MAX(toplevel, obj.topLevel);
    }];
    return toplevel;
}
-(void)topSession:(SessionEntity*)sentity Top:(BOOL)top{
    __block NSInteger toplevel = 0;
    if(top){
        toplevel = [self getTopperSession];
        toplevel++;
    }
    [sentity TopSession:toplevel];
    
}
-(SessionEntity*)GetOrCreateSessionEntityWithUserID:(NSString*)uid{
    SessionEntity* sentity = [_sessions objectForKey:uid];
    if(sentity) return sentity;
    else{
        sentity = [[SessionEntity alloc]initWithSessionID:uid type:SessionTypeSessionTypeSingle];
        
        [self addToSessionModel:sentity];
        [[DDDatabaseUtil instance]updateRecentSession:sentity completion:^(NSError *error) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionCreated object:sentity];
            
        });
        [[ContactModule shareInstance]getUserInfoWithNotification:uid ForUpdate:NO];
        return sentity;
    }
}
-(SessionEntity*)GetOrCreateSessionEntityWithGroupID:(NSString *)gid{
    SessionEntity* sentity = [_sessions objectForKey:gid];
    if(sentity) return sentity;
    else{
        sentity = [[SessionEntity alloc]initWithSessionID:gid type:SessionTypeSessionTypeGroup];
        
        [self addToSessionModel:sentity];
        [[DDDatabaseUtil instance]updateRecentSession:sentity completion:^(NSError *error) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionCreated object:sentity];
        });
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:gid Forupdate:NO];
        return sentity;
    }
}
-(SessionEntity*)GetOrCreateSessionEntityWithSBID:(NSString *)sbid{
    SessionEntity* sentity = [_sessions objectForKey:sbid];
    if(sentity) return sentity;
    else{
        sentity = [[SessionEntity alloc]initWithSessionID:sbid type:SessionTypeSessionTypeSubscription];
        
        [self addToSessionModel:sentity];
        [[DDDatabaseUtil instance]updateRecentSession:sentity completion:^(NSError *error) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionCreated object:sentity];
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeAbstractUpdate object:nil];
        });
        //为了更新
        return sentity;
    }
}
-(void)updateSessionBySession:(SessionEntity *)sentity NewSession:(SessionEntity *)newsentity{
    BOOL change = NO;
    if(sentity.unReadMsgCount != newsentity.unReadMsgCount) change = YES;
    sentity.unReadMsgCount = newsentity.unReadMsgCount;

    if(sentity.timeInterval<newsentity.timeInterval){
        sentity.lastMsg = newsentity.lastMsg;
        sentity.timeInterval = newsentity.timeInterval;
        sentity.lastMsgID = newsentity.lastMsgID;
        change = YES;
    }
    if(change){
        [[DDDatabaseUtil instance]updateRecentSession:sentity completion:^(NSError *error) {
        
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:sentity];
            if(sentity.sessionType == SessionTypeSessionTypeSubscription){
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeAbstractUpdate object:nil];
            }
        });
    }
}
-(void)updateSessionByMessage:(SessionEntity*)sentity Message:(DDMessageEntity*)msgentity{
    if(sentity.timeInterval <= msgentity.msgTime){
        sentity.timeInterval = msgentity.msgTime;
        sentity.lastMsgID = msgentity.msgID;
        
        if(msgentity.msgContentType == DDMessageTypeText){
            sentity.lastMsg = msgentity.msgContent;
        }
        else if(msgentity.msgContentType == DDMessageTypeVoice){
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"语音", nil)];
        }
        else if(msgentity.msgContentType == DDMessageTypeImage){
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"图片", nil)];
            
        }
        else if(msgentity.msgContentType == DDMessageTypeDoc){
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"文件", nil)];
            
        }
        else if(msgentity.msgContentType == DDMessageTypeRichText){
            sentity.lastMsg = [msgentity.info objectForKey:@"title"];
        }
        else if(msgentity.msgContentType == DDMessageTypeVideo){
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"视频", nil)];
            
        }
        else if(msgentity.msgContentType == DDMessageTypeInvite){
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"推荐公众号", nil)];
            
        }else if (msgentity.msgContentType == DDMessageTypeShare) {
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"分享", nil)];
            
        } else {
            sentity.lastMsg = [NSString stringWithFormat:@"[%@]", IMLocalizedString(@"未知消息类型", nil)];
            
        }
        if(![self isSessionOpend:sentity.sessionID]){
            sentity.unReadMsgCount++;
        }
        if(sentity.topLevel !=0 ){
            sentity.topLevel = [self getTopperSession];
        }
        [[DDDatabaseUtil instance]updateRecentSession:sentity completion:^(NSError *error) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:sentity];
            if(sentity.sessionType == SessionTypeSessionTypeSubscription){
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeAbstractUpdate object:nil];
            }
        });

        //notify session update
    }
}
-(void)reportSession:(SessionEntity*)sentity Info:(NSString*)info {
    ReportSessionApi* api = [ReportSessionApi new];
    [api requestWithObject:@[sentity.sessionID,@(sentity.sessionType),info] Completion:^(id response, NSError *error) {
      
    }];
}

-(void)regReciveMessage{
    DDReceiveMessageAPI* api = [DDReceiveMessageAPI new];
    [api registerAPIInAPIScheduleReceiveData:^(NSArray* arrayobj, NSError *error) {
        if(error)return ;

        DDMessageEntity* object = arrayobj[0];
        
        object.state=DDmessageSendSuccess;
        DDReceiveMessageACKAPI *rmack = [[DDReceiveMessageACKAPI alloc] init];
        [rmack requestWithObject:@[object.senderId,@(object.msgID),object.sessionId,@(object.sessionType)] Completion:^(id response, NSError *error) {
            
        }];
        
        [[DDDatabaseUtil instance] insertMessages:@[object] success:^{
            
        } failure:^(NSString *errorDescripe) {
            
        }];
        
        SessionEntity* sentity = nil;
        sentity = [self getSessionById:object.sessionId];
        if(!sentity){
            if(object.sessionType == SessionTypeSessionTypeGroup){
                sentity = [self GetOrCreateSessionEntityWithGroupID:object.sessionId];
            }
            if(object.sessionType == SessionTypeSessionTypeSingle){
                sentity = [self GetOrCreateSessionEntityWithUserID:object.sessionId];
            }
            if(object.sessionType == SessionTypeSessionTypeSubscription){
                sentity = [self GetOrCreateSessionEntityWithSBID:object.senderId];
            }
            sentity.timeInterval = 0;
            assert(sentity);
        }
        [self updateSessionByMessage:sentity Message:object];
        
        if(!sentity.isShield){
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(1007);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReceiveMessage object:arrayobj]; 
        });

        
    }];
}

-(void)refreshSession{
    GetUnreadMessagesAPI* api = [[GetUnreadMessagesAPI alloc]init];
    
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
       
        if(error) return ;
        NSArray<SessionEntity*>* array = [response objectForKey:@"sessions"];
        //首先更新本地会话
        [array enumerateObjectsUsingBlock:^(SessionEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SessionEntity* local = [self getSessionById:obj.sessionID];
            if(local){
                [self updateSessionBySession:local NewSession:obj];
            }
            else{
                [self addToSessionModel:obj];
                [[DDDatabaseUtil instance]updateRecentSession:obj completion:^(NSError *error) {
                    
                }];
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionCreated object:obj];
            }
        }];
        //趴消息
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [array enumerateObjectsUsingBlock:^(SessionEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[DDDatabaseUtil instance]getMessageByIdForSession:obj.sessionID MSGID:obj.lastMsgID completion:^(NSArray *messages, NSError *error) {
                    //这步的目的其实是防止本地已存的消息重复获取
                    if(messages.count == 0){
                        GetMessageQueueAPI *api = [GetMessageQueueAPI new];
                        [api requestWithObject:@[@(obj.lastMsgID),@(obj.unReadMsgCount),@(obj.sessionType),obj.sessionID] Completion:^(NSMutableArray *response, NSError *error) {
                            if(!error && response.count >0){
                                [[DDDatabaseUtil instance]insertMessages:response success:^{
                                    
                                } failure:^(NSString *errorDescripe) {
                                    
                                }];
                                
                                
                                [response enumerateObjectsUsingBlock:^(DDMessageEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                   [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReceiveMessage object:@[obj,@(0)]];
                                }];
                                if([self isSessionOpend:obj.sessionID]){
                                    [self setSessionReadWithSessionID:obj.sessionID];
                                }
                            }
                            
                            
                        }];

                    }
                    
                    
                    
                    
                }];
                
                
            }];
        });

        
    }];
    
    
    
}

-(BOOL)hasSubscribeSession{
    __block BOOL ret = NO;
    [_sessions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, SessionEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj.sessionType == SessionTypeSessionTypeSubscription){
            *stop = YES;
            ret = YES;
        }
    }];
    return ret;
}
-(void)getSubscribeUnread:(NSInteger*)unread LastMessage:(NSString**)lastMsg LastTime:(NSTimeInterval*)lastTime {

    __block NSInteger tmpnnread = 0;
    __block NSTimeInterval tmpLastTime = 0;
   
    [_sessions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, SessionEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj.sessionType != SessionTypeSessionTypeSubscription) return ;
        tmpnnread += obj.unReadMsgCount;
        BOOL isTimeUpdate = tmpLastTime<obj.timeInterval;
        if(isTimeUpdate) {
            tmpLastTime = obj.timeInterval;
            if(lastMsg){
                *lastMsg = obj.lastMsg;
            }
        }
    }];
    
    if(lastTime){
        *lastTime = tmpLastTime;
    }
    if(unread){
        *unread = tmpnnread;
    }
    
}


-(void)clear{
    [_sessions removeAllObjects ];
    [_sessionState removeAllObjects];
}

@end
