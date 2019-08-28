//
//  DDReceiveGroupAddMemberAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDReceiveGroupchangeMemberAPI.h"
#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "GroupEntity.h"
#import "DDUserEntity.h"
#import "IMGroup.pb.h"
@implementation DDReceiveGroupChangeMemberAPI
/**
 *  数据包中的serviceID
 *
 *  @return serviceID
 */
- (int)responseServiceID
{
    return SERVICE_GROUP;
}

/**
 *  数据包中的commandID
 *
 *  @return commandID
 */
- (int)responseCommandID
{
    return GroupCmdIDCidGroupChangeMemberNotify;
}

/**
 *  解析数据包
 *
 *  @return 解析数据包的block
 */
- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData* data)
    {
        IMGroupChangeMemberNotify* chgnotify = [IMGroupChangeMemberNotify parseFromData:data];
        
        NSLog(@" ----------------------- ");
        NSString* gid = [GroupEntity pbGroupIdToLocalID:chgnotify.groupId];
        NSString* modifyer = [DDUserEntity pbUserIdToLocalID:chgnotify.userId];
        NSMutableArray* cur_users = [NSMutableArray new];
        NSMutableArray* chg_users = [NSMutableArray new];
        
        NSUInteger userCnt = [chgnotify.curUserIdList count];
        for (NSUInteger i = 0; i < userCnt; i++) {
            NSString* userId = [TheRuntime changeOriginalToLocalID:[chgnotify.curUserIdList[i] integerValue] SessionType:SessionTypeSessionTypeSingle];
            [cur_users addObject:userId];
        }
        
        NSUInteger chgcnt = [chgnotify.chgUserIdList count];
        for(NSInteger i = 0 ; i < chgcnt;++i){
            NSString* userId = [TheRuntime changeOriginalToLocalID:[chgnotify.chgUserIdList[i] integerValue] SessionType:SessionTypeSessionTypeSingle];
            [chg_users addObject:userId];
        }
        return @[gid,modifyer,cur_users,chg_users,@(chgnotify.changeType)];
    };
    return analysis;
}
@end
