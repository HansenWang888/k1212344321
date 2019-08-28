#ifndef _SESSION_ENTITY_H
#define _SESSION_ENTITY_H
//
//  DDSessionEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"
@class DDUserEntity,GroupEntity;
//typedef enum
//{
//    SESSIONTYPE_SINGLE = 1,          //单个用户会话
//    SESSIONTYPE_TEMP_GROUP = 2,           //群会话
//    SESSIONTYPE_GROUP =3
//}SessionType;

@interface SessionEntity : NSObject
@property (nonatomic,retain)NSString* sessionID;
@property (nonatomic,assign)SessionType sessionType;
@property (nonatomic,readonly)NSString* name;
@property(assign)NSInteger unReadMsgCount;
@property (assign)NSUInteger timeInterval;
@property(nonatomic,strong,readonly)NSString* orginId;
@property(assign)NSUInteger isShield;
@property(assign)NSInteger topLevel;
@property(assign)NSUInteger showNick;
@property(strong)NSString *lastMsg;
@property(assign)NSInteger lastMsgID;
@property(strong)NSString *avatar;
-(NSArray*)sessionUsers;
/**
 *  创建一个session，只需赋值sessionID和Type即可
 *
 *  @param sessionID 会话ID，群组传入groupid，p2p传入对方的userid
 *  @param type      会话的类型
 *
 *  @return 
 */
- (id)initWithSessionID:(NSString*)sessionID type:(SessionType)type;

- (id)initWithSessionIDByUser:(DDUserEntity*)user;
- (id)initWithSessionIDByGroup:(GroupEntity*)group;
- (void)updateUpdateTime:(NSUInteger)date;
-(NSString *)getSessionGroupID;
-(void)setSessionName:(NSString *)theName;
-(BOOL)isGroup;
-(id)dicToGroup:(NSDictionary *)dic;
-(void)setSessionUser:(NSArray *)array;

-(void)SessionShowNick:(NSUInteger)showNick;
-(void)SessionDND:(NSUInteger)shield;
-(void)TopSession:(NSInteger)toplevel;

@end
#endif
