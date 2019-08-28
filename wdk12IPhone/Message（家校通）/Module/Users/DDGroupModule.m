//
//  DDGroupModule.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "GetGroupInfoAPi.h"
#import "DDReceiveGroupchangeMemberAPI.h"
#import "DDDatabaseUtil.h"
//#import "GroupAvatarImage.h"
#import "DDNotificationHelp.h"
#import "NSDictionary+Safe.h"
#import "DDMessageEntity.h"
#import "SessionModule.h"
#import "IMGroup.pb.h"
#import "ContactModule.h"
#import "DDCreateGroupAPI.h"
#import "DDAddMemberToGroupAPI.h"
#import "modifyGroupInfo.h"
#import "DDDeleteMemberFromGroupAPI.h"
#import "QuitGroupapi.h"
@implementation DDGroupModule
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allGroups = [NSMutableDictionary new];
        [self registerAPI];
    }
    return self;
}

-(void) clear{
    [self.allGroups removeAllObjects];
}
+ (instancetype)instance
{
    static DDGroupModule* group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = [[DDGroupModule alloc] init];
        
    });
    return group;
}
-(void)getGroupFromDB
{
    
}
-(void)addGroup:(GroupEntity*)newGroup
{
    if (!newGroup)
    {
        return;
    }
    GroupEntity* group = newGroup;
    [_allGroups setObject:group forKey:group.objID];
    newGroup = nil;
}
-(void)addGroups:(NSArray*)groups{
    [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addGroup:obj];
    }];
}
-(void)clearLocalMessage:(NSString*)sbID{
    [[DDDatabaseUtil instance]deleteMesagesForSession:sbID completion:^(BOOL success) {
        
    }];
}
-(NSArray*)getAllGroups
{
    return [_allGroups allValues];
}
-(GroupEntity*)getGroupByGId:(NSString*)gId
{
    GroupEntity *entity= [_allGroups safeObjectForKey:gId];
    return entity;
}

- (void)getGroupInfogroupID:(NSString*)groupID completion:(GetGroupInfoCompletion)completion
{
    GroupEntity *group = [self getGroupByGId:groupID];
    if (group) {
        completion(group);
    }else{
        GetGroupInfoAPI* request = [[GetGroupInfoAPI alloc] init];
        [request requestWithObject:@[@([TheRuntime changeIDToOriginal:groupID]),@(group.objectVersion)] Completion:^(id response, NSError *error) {
            if (!error)
            {
                if ([response count]) {
                    GroupEntity* group = (GroupEntity*)response[0];
                    if (group)
                    {
                        [self addGroup:group];
                       [[DDDatabaseUtil instance] updateRecentGroup:group completion:^(NSError *error) {
                            WDULog(@"insert group to database error.");
                        }];
                    }
                    completion(group);
                }
                
            }
        }];
    }
    
}
-(void)getGroupInfoFromServer:(NSString*)groupID completion:(GetGroupInfoCompletion)completion{
    GroupEntity *group = [self getGroupByGId:groupID];

    NSInteger objversion = 0;
    if(group) objversion = group.objectVersion;
    GetGroupInfoAPI* request = [[GetGroupInfoAPI alloc] init];
    [request requestWithObject:@[@([TheRuntime changeIDToOriginal:groupID]),@(objversion)] Completion:^(id response, NSError *error) {
        if (!error)
        {
            if ([response count]) {
                GroupEntity* group = (GroupEntity*)response[0];
                if (group)
                {
                    [self addGroup:group];
                    [[DDDatabaseUtil instance] updateRecentGroup:group completion:^(NSError *error) {
                        
                    }];
                }
                completion(group);
            }
            
        }
    }];
}
-(GroupEntity*)getGroupInfoFromServerWithNotify:(NSString*)gid Forupdate:(BOOL)update{
    GroupEntity* gentity = [_allGroups objectForKey:gid];
    
    if(!gentity || update){
        
        [self getGroupInfoFromServer:gid completion:^(GroupEntity *group) {

            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationGroupUpdated object:@[gid,@(GROUP_NOTIFY_OTHER|GROUP_NOTIFY_MEMBER)]];
            
        }];
    }
    return gentity;
}
-(void)CreateGroup:(NSArray*)uids GroupName:(NSString*)name Block:(CreateGroupCompletion)block{

    DDCreateGroupAPI* api = [DDCreateGroupAPI new];

    NSMutableArray* array = [[NSMutableArray alloc]initWithArray:uids];
    [array addObject:TheRuntime.user.objID];
    
    
    [api requestWithObject:@[name,@"",array] Completion:^(id response, NSError *error) {
        if(!error){
            GroupEntity* gentity = response;
            [[DDDatabaseUtil instance]updateRecentGroup:gentity completion:^(NSError *error) {
                
            }];
            [self addGroup:gentity];
            block(nil,gentity);
        }
        else{
            block(error,nil);
        }
        
    }];
}
-(void)addMemberToGroup:(NSArray*)uids GroupID:(NSString*)gid Block:(UpdateGroupCompletion)block{

    GroupEntity* gentity = [self getGroupByGId:gid];
    if(gentity == nil) {
        block([NSError errorWithDomain:IMLocalizedString(@"没有这个群组", nil) code:0 userInfo:nil],nil);
        return;
    }
    
    DDAddMemberToGroupAPI* api = [DDAddMemberToGroupAPI new];
    
    [api requestWithObject:@[gid,uids] Completion:^(id response, NSError *error) {
        
        
        
        if(!error){
            NSInteger code = [[response objectAtIndex:0]integerValue];
            if(code != 0){
                block([NSError errorWithDomain:IMLocalizedString(@"服务器异常", nil) code:code userInfo:nil],nil);
                return ;
            }
            NSMutableArray* curlist = [response objectAtIndex:1];
            NSMutableArray* chglist = [response objectAtIndex:2];
            assert(curlist);
            assert(chglist);
            gentity.groupUserIds = curlist;
            if(chglist.count >0){
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationGroupUpdated object:@[gentity.objID,@(GROUP_NOTIFY_MEMBER)]];
            }
            block(nil,response);
        }
        else{
            block(error,nil);
        }
        
    }];
}
-(void)delMemberFromGroup:(NSArray*)uids GroupID:(NSString*)gid Block:(UpdateGroupCompletion)block{
    
    GroupEntity* gentity = [self getGroupByGId:gid];
    if(gentity == nil) {
        block([NSError errorWithDomain:IMLocalizedString(@"没有这个群组", nil) code:0 userInfo:nil],nil);
        return;
    }
    
    DDDeleteMemberFromGroupAPI* api = [DDDeleteMemberFromGroupAPI new];
    
    [api requestWithObject:@[gid,uids] Completion:^(id response, NSError *error) {
        
        
        
        if(!error){
            NSInteger code = [[response objectAtIndex:0]integerValue];
            if(code != 0){
                block([NSError errorWithDomain:IMLocalizedString(@"服务器异常", nil) code:code userInfo:nil],nil);
                return ;
            }
            NSMutableArray* curlist = [response objectAtIndex:1];
            NSMutableArray* chglist = [response objectAtIndex:2];
            assert(curlist);
            assert(chglist);
            gentity.groupUserIds = curlist;
            if(chglist.count >0){
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationGroupUpdated object:@[gentity.objID,@(GROUP_NOTIFY_MEMBER)]];
            }
            block(nil,response);
        }
        else{
            block(error,nil);
        }
        
    }];
}
//gid type value
-(void)modifyGroupName:(NSString*)gid GroupName:(NSString*)gname Block:(UpdateGroupCompletion)block{
    GroupEntity* gentity = [self getGroupByGId:gid];
    if(gentity == nil) {
        block([NSError errorWithDomain:IMLocalizedString(@"没有这个群组", nil) code:0 userInfo:nil],nil);
        return;
    }
    ModifyGroupInfoApi* api = [ModifyGroupInfoApi new];
    
    [api requestWithObject:@[gid,@(GroupModifyTypeGroupModifyTypeNewname),gname] Completion:^(id response, NSError *error) {
       
        if(!error){
            NSInteger code = [response integerValue];
            if(code != 0){
                block([NSError errorWithDomain:IMLocalizedString(@"服务器异常", nil) code:code userInfo:nil],nil);
                return ;
            }
            gentity.name = gname;
            [[DDDatabaseUtil instance]updateRecentGroup:gentity completion:^(NSError *error) {
                
            }];
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationGroupUpdated object:@[gentity.objID,@(GROUP_NOTIFY_OTHER)]];

            block(nil,response);
        }
        else{
            block(error,nil);
        }
    }];
}
-(void)modifyGroupMyNick:(NSString*)gid MyNick:(NSString*)mynick Block:(UpdateGroupCompletion)block{
    GroupEntity* gentity = [self getGroupByGId:gid];
    if(gentity == nil) {
        block([NSError errorWithDomain:IMLocalizedString(@"没有这个群组", nil) code:0 userInfo:nil],nil);
        return;
    }
    ModifyGroupInfoApi* api = [ModifyGroupInfoApi new];
    
    [api requestWithObject:@[gid,@(GroupModifyTypeGroupModifyTypeNewusernick),mynick] Completion:^(id response, NSError *error) {
        
        if(!error){
            NSInteger code = [response integerValue];
            if(code != 0){
                block([NSError errorWithDomain:IMLocalizedString(@"服务器异常", nil) code:code userInfo:nil],nil);
                return ;
            }
            [gentity setGroupNick:TheRuntime.user.objID Nick:mynick];
            [[DDDatabaseUtil instance]updateRecentGroup:gentity completion:^(NSError *error) {
                
            }];
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationGroupUpdated object:@[gentity.objID,@(GROUP_NOTIFY_OTHER)]];
            
            block(nil,response);
        }
        else{
            block(error,nil);
        }
    }];

}
-(void)quitGroup:(NSString*)gid Block:(UpdateGroupCompletion)block{
    QuitGroupApi* api = [QuitGroupApi new];
    
    [api requestWithObject:@[gid] Completion:^(id response, NSError *error) {
        if(!error){
            NSInteger code = [[response objectAtIndex:0]integerValue];
            if(code==0){
                //如果在通讯录里，通讯录删除
                ContactInfoEntity *centity = [[ContactModule shareInstance] GetContactInfoByID:gid];
                if (centity) {
                    centity.status = 1;
                    [[DDDatabaseUtil instance] insertContacts:@[centity] Block:^(NSError *error) {
                    }];
                    //通知通讯录数据库更新
                    [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationContactUpdateGroup object:centity];
                }
                
                //发群删除
                SessionEntity* sentity = [[SessionModule sharedInstance]getSessionById:gid];
                if(sentity){
                    [[SessionModule sharedInstance]removeSessionByServer:sentity];
                }
                block(nil,nil);
            }
            else{
                block([NSError errorWithDomain:@"quitGrouperror" code:code userInfo:nil],nil);
            }
        }
        else{
            block(error,nil);
        }
    }];
}
- (void)registerAPI
{
    return;
    DDReceiveGroupChangeMemberAPI* api = [DDReceiveGroupChangeMemberAPI new];
    
    
    //0 gid 1  uid  2 cur_users 3 chg_users 4 changetype
    [api registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if(!error){
            if(object == nil) return ;
            NSString* groupid = object[0];
            
            GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:groupid];
            if(!gentity) return;
            
            gentity.groupUserIds = object[2];
            GroupModifyType changetype = [object[4] integerValue];
            
            __block BOOL hasme = NO;
            [gentity.groupUserIds enumerateObjectsUsingBlock:^(NSString* uid, NSUInteger idx, BOOL *stop) {
                if([uid isEqualToString:TheRuntime.user.objID]){
                    hasme = YES;
                    *stop = YES;
                }
            }];
            
            if(!hasme){
                gentity.InContact = 0;
            }
            
            
            [[DDDatabaseUtil instance]updateRecentGroup:gentity completion:^(NSError *error) {
                
            }];
            [[DDGroupModule instance]addGroup:gentity];
            NSString* modifier = object[1];
           
            

            
            
            switch (changetype) {
                case GroupModifyTypeGroupModifyTypeAdd:
                    
                    break;
                case GroupModifyTypeGroupModifyTypeDel:
                    
                    break;
                case GroupModifyTypeGroupModifyTypeQuit:
                    if([modifier isEqualToString:gentity.groupCreatorId]){
                        [self getGroupInfoFromServer:groupid completion:^(GroupEntity *group) {
                           //do nothing
                        }];
                    }
                    break;
                default:
                    break;
            }
        }
    }];
}


@end
