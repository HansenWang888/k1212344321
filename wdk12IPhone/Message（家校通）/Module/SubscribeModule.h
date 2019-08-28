//
//  SubscribeModule.h
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"
@class  SubscribeEntity;

typedef  NS_ENUM(NSInteger,SubscribeUpdateType){
    SubscribeUpdateTypeInfo,
    SubscribeUpdateTypeMenu
};

typedef void(^SubscribeAttentionCompeletion)(NSError* error);
typedef void(^SubscribeInfoCompeletion)(SubscribeEntity* sbentity);
typedef void(^SearchSubscribeCompeletion)(NSArray<SubscribeEntity*>* sbAry);
typedef void(^PullSubscribeMessageCompeletion)(NSArray* msgAry);
@interface SubscribeAttentionEntity : DDBaseEntity
+(id)initWithPB:(SubscribeAttentionInfo*)pbinfo;
@property NSString* differno;
@property NSString* uuid;
@end

@interface SubscribeModule : NSObject

+(instancetype)shareInstance;

-(void)loadFromDB;
-(void)clear;
-(SubscribeEntity*)getSubscribeBySBID:(NSString*)sbid;
-(SubscribeAttentionEntity*)getAttentionBySBID:(NSString*)sbid;
-(NSArray*)getSubs;
-(void)insertToModule:(SubscribeEntity*)sbEntity;
-(NSString*)getSBMenuBySBID:(NSString*)sbid;

-(void)UpdateSubscribeList;
-(void)attentionSubscribe:(NSString*)sb_id Attention:(SubscribeOpt)opt Block:(SubscribeAttentionCompeletion) block;

-(SubscribeEntity*)getSBInfoWithNotification:(NSString *)sbid ForUpdate:(BOOL)update;
-(NSString*)getSBMenuInfoWithNotification:(NSString*)sbid ForUpdate:(BOOL)update;
-(void)getSubscribeByUUID:(NSString*)uuid Differno:(NSString*)differno Block:(SubscribeInfoCompeletion)block;

-(void)SearchSubscribe:(NSString*)key Block:(SearchSubscribeCompeletion)block;
//获取历史消息
-(void)pullHistoryMessage:(NSString*)sbID LastMsgID:(NSInteger)lastMsgID PullCnt:(NSInteger)cnt Block:(PullSubscribeMessageCompeletion)block;

//清除会话
-(void)clearLocalMessage:(NSString*)sbID;
@end
