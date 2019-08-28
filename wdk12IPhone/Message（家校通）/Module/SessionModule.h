//
//  SessionModule.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-12-05.
//  Copyright (c) 2014 dujia. All rights reserved.
//
#ifndef SESSION_MODULE_H
#define SESSION_MODULE_H
#import <Foundation/Foundation.h>
#import "std.h"
@class DDMessageEntity;
@class SessionEntity;
typedef enum
{
    ADD = 0,
    REFRESH = 1,
    DELETE =2
}SessionAction;

typedef enum
{
    NORMAL = 0,
    OPEN = 1,
    HIDE = 2
} SessionState;

typedef  void(^NetUnverseBlock)(NSError* error);

@interface SessionModule : NSObject
AS_SINGLETON(SessionModule)
-(NSArray *)getAllSessions;

-(void)addToSessionModel:(SessionEntity *)session;
-(void)addSessionsToSessionModel:(NSArray *)sessionArray;
-(SessionEntity *)getSessionById:(NSString *)sessionID;

-(void)removeSessionByServer:(SessionEntity *)session;
-(void)removeSessionLocal:(SessionEntity*)session;
-(void)clearSession:(SessionEntity*)session;

-(void)loadLocalSession:(void(^)(bool isok))block;
-(void)setSessionOpened:(NSString*)sid Opened:(BOOL)opened;
-(BOOL)isSessionOpend:(NSString*)sid;

-(void)setSessionRead:(SessionEntity*)session;
-(void)topSession:(SessionEntity*)sentity Top:(BOOL)top;

-(SessionEntity*)GetOrCreateSessionEntityWithUserID:(NSString*)uid;
-(SessionEntity*)GetOrCreateSessionEntityWithGroupID:(NSString *)gid;
-(SessionEntity*)GetOrCreateSessionEntityWithSBID:(NSString *)sbid;

-(void)updateSessionByMessage:(SessionEntity*)sentity Message:(DDMessageEntity*)msgentity;

-(void)reportSession:(SessionEntity*)sentity Info:(NSString*)info ;
-(void)clear;

//
-(BOOL)hasSubscribeSession;
-(void)getSubscribeUnread:(NSInteger*)unread LastMessage:(NSString**)lastMsg LastTime:(NSTimeInterval*)lastTime ;


@end
#endif