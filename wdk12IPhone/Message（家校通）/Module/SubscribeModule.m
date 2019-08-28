//
//  SubscribeModule.m
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import "ListSubscribes.h"
#import "SubscribeAttentionAPI.h"
#import "SubscribeMenuInfo.h"
#import "GetSubscribeInfo.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "DDDatabaseUtil.h"
#import "SearchSubscribeAPI.h"
//#import "DDMessageEntity.h"
#import "GetMessageQueueAPI.h"
@implementation SubscribeAttentionEntity

+(id)initWithPB:(SubscribeAttentionInfo *)pbinfo{
    SubscribeAttentionEntity* entity = [SubscribeAttentionEntity new];
    entity.uuid = pbinfo.sbUuid;
    entity.differno = pbinfo.sbDifferno;
    entity.objID = [TheRuntime changeOriginalToLocalID:pbinfo.sbId SessionType:SessionTypeSessionTypeSubscription];
    return entity;
}

@end

@implementation SubscribeModule{
    NSMutableDictionary<NSString*,SubscribeEntity*>* _subs;
    NSMutableDictionary<NSString*,SubscribeAttentionEntity*>* _attsbs;
    NSMutableDictionary<NSString*,NSString*>* _sbmenus;
}
+(instancetype)shareInstance{
    static SubscribeModule* g_contactModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_contactModule = [[SubscribeModule alloc] init];
    });
    return g_contactModule;
}

-(id)init{
    self = [super init];
    _subs = [NSMutableDictionary new];
    _attsbs = [NSMutableDictionary new];
    _sbmenus = [NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UpdateSubscribeList) name:DDNotificationUserLoginSuccess object:nil];
    return self;
}
-(void)loadFromDB{
    //加载关注实体
    [[DDDatabaseUtil instance]loadSubscribeAttention:^(NSArray *attentions) {
        [attentions enumerateObjectsUsingBlock:^(SubscribeAttentionEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_attsbs setObject:obj forKey:obj.objID];
        }];
    }];
    //加载公众号实体
    [[DDDatabaseUtil instance]loadSubscribe:^(NSArray *subscribes) {
       [subscribes enumerateObjectsUsingBlock:^(SubscribeEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           [_subs setObject:obj forKey:obj.objID];
       }];
        
    }];
    //加载菜单实体
    [[DDDatabaseUtil instance]loadSubscribeMenu:^(NSDictionary *menus) {
        [menus enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_sbmenus setObject:obj forKey:key];
        }];
        
    }];
}
-(void)clear{
    [_subs removeAllObjects];
    [_attsbs removeAllObjects];
    [_sbmenus removeAllObjects];
}
-(SubscribeEntity*)getSubscribeBySBID:(NSString*)sbid{
    return [_subs objectForKey:sbid];
}
-(void)insertToModule:(SubscribeEntity*)sbEntity{
    [_subs setObject:sbEntity forKey:sbEntity.objID];
}
-(NSArray*)getSubs{
    return [_attsbs allValues];
}

-(void)attentionSubscribe:(NSString*)sb_id Attention:(SubscribeOpt)opt Block:(SubscribeAttentionCompeletion) block{
    SubscribeEntity* sbentity = [self getSubscribeBySBID:sb_id];
    if(sbentity == nil){
        block([NSError errorWithDomain:@"attentionSubscribe nil" code:0 userInfo:nil]);
        
        return;
    }
    SubscribeAttentionAPI* api = [SubscribeAttentionAPI new];
    [api requestWithObject:@[sbentity.uuid,@(opt)] Completion:^(id response, NSError *error) {
        if(!error){
            NSInteger code = [response integerValue];
            if(code == SubscribeRetCodeSubscribeRetOk){
                if(opt == SubscribeOptSubscribe){
                    [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationAttentionSuccessful object:sb_id];
                    SubscribeAttentionEntity* sbattentity = [SubscribeAttentionEntity new];
                    sbattentity.uuid = sbentity.uuid;
                    sbattentity.objID = sbentity.objID;
                    sbattentity.differno = sbentity.fkbh;
                    [_attsbs setObject:sbattentity forKey:sbentity.objID];
                }
                if(opt == SubscribeOptCancelsubscribe){
                    [_attsbs removeObjectForKey:sbentity.objID];
                    SessionEntity* sentity = [[SessionModule sharedInstance]getSessionById:sbentity.objID];
                    if(sentity){
                        [[SessionModule sharedInstance]removeSessionByServer:sentity];
                    }
                }
                block(nil);
            }
            else{
                
                block([NSError errorWithDomain:@"attentionSubscribe" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
    }];
}
-(void)UpdateSubscribeList{
    ListSubscribeAPI* api = [ListSubscribeAPI new];
    
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        if(!error && response){
            [[DDDatabaseUtil instance]removeAllAttentionSubscribe];
            [_attsbs removeAllObjects ];
            [[DDDatabaseUtil instance]insertAttention:response Block:^(NSError *error) {
            }];
            [response enumerateObjectsUsingBlock:^(SubscribeAttentionEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [_attsbs setObject:obj forKey:obj.objID];
             
                [self getSBInfoWithNotification:obj.objID ForUpdate:NO];
                
            }];
            //删除所有非本地的会话
            [[[SessionModule sharedInstance]getAllSessions] enumerateObjectsUsingBlock:^(SessionEntity*  _Nonnull sentity, NSUInteger idx, BOOL * _Nonnull stop) {
                if(sentity.sessionType == SessionTypeSessionTypeSubscription &&
                   [_attsbs objectForKey:sentity.sessionID]==nil){
                    [[SessionModule sharedInstance]removeSessionLocal:sentity];
                }
            }];
        }
        else{
            
        }
        
        
    }];
}
-(SubscribeAttentionEntity*)getAttentionBySBID:(NSString*)sbid{
    return [_attsbs objectForKey:sbid];
}

-(SubscribeEntity*)getSBInfoWithNotification:(NSString *)sbid ForUpdate:(BOOL)update{
    SubscribeEntity* ret = [self getSubscribeBySBID:sbid];
    
    if(ret == nil || update){
        SubscribeAttentionEntity* sbattentity = [self getAttentionBySBID:sbid];
        if(sbattentity == nil) {
            WDULog(@"require or update sbentity not attention:%@",sbid);
            return nil;
        }
        GetSubscribeInfoAPI* api = [GetSubscribeInfoAPI new];
        [api requestWithObject:@[@"",@"",sbid] Completion:^(id response, NSError *error) {
            if(!error){
                if(response&& [response count]>0){
                    SubscribeEntity* sbentity = response[0];
                    [self insertToModule:sbentity];
                    [[DDDatabaseUtil instance]insertSubscribes:@[sbentity] Block:^(NSError *error) {
                        
                    }];
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeInfoUpdate object:@[sbentity.objID,@(SubscribeUpdateTypeInfo)]];
                }
            }
            else{
                
            }
        }];
        
        
        
    }
    return ret;
}
-(void)getSubscribeByUUID:(NSString*)uuid Differno:(NSString*)differno Block:(SubscribeInfoCompeletion)block{
    
 //   dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        __block BOOL isFind;
//        [_subs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SubscribeEntity * _Nonnull obj, BOOL * _Nonnull stop) {
//            if([obj.uuid isEqualToString:uuid] ){
//                block(obj);
//                *stop = YES;
//                _
//            }
//        }];
        
        GetSubscribeInfoAPI* api = [GetSubscribeInfoAPI new];
        [api requestWithObject:@[uuid,differno,@"sb_0"] Completion:^(id response, NSError *error) {
            
            if(!error){
                if(response&& [response count]>0){
                    SubscribeEntity* sbentity = response[0];
                    [self insertToModule:sbentity];
                    [[DDDatabaseUtil instance]insertSubscribes:@[sbentity] Block:^(NSError *error) {
                        
                    }];
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeInfoUpdate object:@[sbentity.objID,@(SubscribeUpdateTypeInfo)]];
                    block(sbentity);
                }
                else{
                    block(nil);
                }
            }
            else{
                block(nil);
            }
        }];

 //   });
}
-(NSString*)getSBMenuBySBID:(NSString*)sbid{
    return [_sbmenus objectForKey:sbid];
}
-(NSString*)getSBMenuInfoWithNotification:(NSString*)sbid ForUpdate:(BOOL)update{
    
    NSString* menu = [_sbmenus objectForKey:sbid];
    
    if(menu == nil|| update){
        SubscribeAttentionEntity* sbattentity = [self getAttentionBySBID:sbid];
        if(sbattentity == nil) {
            WDULog(@"require or update sbentity not attention:%@",sbid);
            return nil;
        }
        
        SubscribeMenuInfoAPI* api = [SubscribeMenuInfoAPI new];
        [api requestWithObject:sbattentity.uuid Completion:^(id response, NSError *error) {
            if(!error){
                SubscribeRetCode code = [response[0] integerValue];
                if(code == SubscribeRetCodeSubscribeRetOk){
                    NSString* menu = response[1];
                    [_sbmenus setObject:menu forKey:sbid];
                    [[DDDatabaseUtil instance]insertSubscribeMenu:sbid Menu:menu Block:^(NSError *error) {
                        
                    }];
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSubscribeInfoUpdate object:@[sbid,@(SubscribeUpdateTypeMenu)]];
                }
            }
        }];
    }
    return menu;
}
-(void)SearchSubscribe:(NSString*)key Block:(SearchSubscribeCompeletion)block{
    SearchSubscribeAPI* api = [SearchSubscribeAPI new];
    [api requestWithObject:key Completion:^(id response, NSError *error) {
        if(!error){
            [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self insertToModule:obj];
            }];
            block(response);
        }
    }];
}
-(void)pullHistoryMessage:(NSString*)sbID LastMsgID:(NSInteger)lastMsgID PullCnt:(NSInteger)cnt Block:(PullSubscribeMessageCompeletion)block{
//    [getMsgListReq setMsgIdBegin:[array[0] integerValue]];
//    [getMsgListReq setUserId:0];
//    [getMsgListReq setMsgCnt:[array[1] integerValue]];
//    [getMsgListReq setSessionType: [array[2] integerValue]];
//    [getMsgListReq setSessionId:[TheRuntime changeIDToOriginal:array[3]]];
    GetMessageQueueAPI* api = [GetMessageQueueAPI new];
    [api requestWithObject:@[@(lastMsgID),@(cnt),@(SessionTypeSessionTypeSubscription),sbID ]Completion:^(id response, NSError *error) {
        if(!error){


            block(response);
        }
        else{
            block(@[]);
        }
    }];
}
-(void)clearLocalMessage:(NSString*)sbID{
    [[DDDatabaseUtil instance]deleteMesagesForSession:sbID completion:^(BOOL success) {
        
    }];
}
@end
