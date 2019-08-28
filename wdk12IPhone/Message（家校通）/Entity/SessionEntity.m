//
//  DDSessionEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "SessionEntity.h"
#import "DDUserModule.h"
#import "DDDatabaseUtil.h"
#import "GroupEntity.h"
#import "DDGroupModule.h"
#import "DDMessageModule.h"
#import "DDUserEntity.h"
#import "GroupEntity.h"
#import "ContactModule.h"
@implementation SessionEntity
@synthesize  name;
@synthesize timeInterval;
- (void)setSessionID:(NSString *)sessionID
{
    _sessionID = [sessionID copy];
    name = nil;
    timeInterval = 0;
}

- (void)setSessionType:(SessionType)sessionType
{
    _sessionType = sessionType;
    name = nil;
    timeInterval = 0;
}

- (NSString*)name
{
    switch (self.sessionType)
    {
        case SessionTypeSessionTypeSingle:
        {
            ContactInfoEntity* centity =  [[ContactModule shareInstance]GetContactInfoByID:_sessionID];
            if(centity && [centity hasRmkname]) name = centity.rmkname;
            else {
                [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(DDUserEntity *user) {
                    if ([user.nick length] > 0)
                    {
                        name = user.nick;
                    }
                    else
                    {
                        name = user.name;
                    }
                    
                }];
            }
        }
            break;
        case SessionTypeSessionTypeGroup:
        {
            GroupEntity* group = [[DDGroupModule instance] getGroupByGId:_sessionID];
            if(group) name = group.name;
        }
            break;
            
    }
    if(!name) name = @"";
    return name;
}
-(void)setSessionName:(NSString *)theName
{
    name = theName;
}

-(void)SessionShowNick:(NSUInteger)showNick{
    if(_showNick == showNick) return;
    _showNick = showNick;
    [[DDDatabaseUtil instance]updateRecentSession:self completion:^(NSError *error) {
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:self];
    });
}
-(void)SessionDND:(NSUInteger)shield{
    if(_isShield== shield) return;
    _isShield = shield;
    [[DDDatabaseUtil instance]updateRecentSession:self completion:^(NSError *error) {
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:self];
    });
}
-(void)TopSession:(NSInteger)toplevel{
    
    if(_topLevel != toplevel){
        _topLevel = toplevel;
    }
    
    [[DDDatabaseUtil instance]updateRecentSession:self completion:^(NSError *error) {
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationSessionUpdated object:self];
    });
}

#pragma mark -
#pragma mark Public API

- (id)initWithSessionID:(NSString*)sessionID type:(SessionType)type
{
    self = [super init];
    if (self)
    {
        self.sessionID = sessionID;
        self.sessionType = type;
        self.unReadMsgCount=0;
        self.lastMsg=@"";
        self.lastMsgID=0;
        self.timeInterval= [[NSDate date] timeIntervalSince1970];
        self.topLevel = 0;
        self.showNick = YES;
    }
    return self;
}

- (void)updateUpdateTime:(NSUInteger)date
{
    timeInterval = date;
    self.timeInterval = timeInterval;
    [[DDDatabaseUtil instance] updateRecentSession:self completion:^(NSError *error) {
        
    }];
    
}
-(NSArray*)sessionUsers
{
    if(SessionTypeSessionTypeGroup == self.sessionType)
    {
        GroupEntity* group = [[DDGroupModule instance] getGroupByGId:_sessionID];
        return group.groupUserIds;
    }
    
    return  nil;
}
-(NSString *)getSessionGroupID
{
    return _sessionID;
}
-(BOOL)isGroup
{
    if(SessionTypeSessionTypeGroup == self.sessionType)
    {
        return YES;
    }
    return NO;
}

- (id)initWithSessionIDByUser:(DDUserEntity*)user
{
    SessionEntity *session = [self initWithSessionID:user.objID type:SessionTypeSessionTypeSingle];
    [session setSessionName:user.name];
    return session;
}
- (id)initWithSessionIDByGroup:(GroupEntity*)group
{
    SessionType sessionType =SessionTypeSessionTypeGroup;
    SessionEntity *session = [self initWithSessionID:group.objID type:sessionType];
    [session setSessionName:group.name];
    
    return session;
}
+(id)initWithDicToGroup:(NSDictionary *)dic
{
    SessionEntity *session =[SessionEntity new];
    return session;
}
- (BOOL)isEqual:(id)other
{
    
    if (other == self) {
        return YES;
    }  else if([self class] != [other class])
    {
        return NO;
    }else {
        SessionEntity *otherSession = (SessionEntity *)other;
        if (![self.sessionID isEqualToString:otherSession.sessionID]) {
            return NO;
        }
        if (self.sessionType != otherSession.sessionType) {
            return NO;
        }
        
        
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger sessionIDhash = [self.sessionID hash];
    
    return sessionIDhash^self.sessionType;
}




@end
