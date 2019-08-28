//
//  DDGroupModule.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupEntity.h"
typedef void(^GetGroupInfoCompletion)(GroupEntity* group);
typedef void(^CreateGroupCompletion)(NSError*, GroupEntity* group);
typedef void(^UpdateGroupCompletion)(NSError*,id respone);
@interface DDGroupModule : NSObject
+ (instancetype)instance;
@property(assign)NSInteger recentGroupCount;
@property(strong) NSMutableDictionary* allGroups;         //所有群列表,key:group id value:GroupEntity
@property(strong) NSMutableDictionary* allFixedGroup;     //所有固定群列表
-(GroupEntity*)getGroupByGId:(NSString*)gId;
-(void)addGroup:(GroupEntity*)newGroup;
-(void)addGroups:(NSArray*)groups;
- (void)getGroupInfogroupID:(NSString*)groupID completion:(GetGroupInfoCompletion)completion;
-(void)getGroupInfoFromServer:(NSString*)groupID completion:(GetGroupInfoCompletion)completion;
-(NSArray*)getAllGroups;


-(GroupEntity*)getGroupInfoFromServerWithNotify:(NSString*)gid Forupdate:(BOOL)update;

-(void)CreateGroup:(NSArray*)uids GroupName:(NSString*)name Block:(CreateGroupCompletion)block;
-(void)addMemberToGroup:(NSArray*)uids GroupID:(NSString*)gid Block:(UpdateGroupCompletion)block;
-(void)delMemberFromGroup:(NSArray*)uids GroupID:(NSString*)gid Block:(UpdateGroupCompletion)block;
-(void)modifyGroupName:(NSString*)gid GroupName:(NSString*)gname Block:(UpdateGroupCompletion)block;
-(void)modifyGroupMyNick:(NSString*)gid MyNick:(NSString*)mynick Block:(UpdateGroupCompletion)block;
-(void)quitGroup:(NSString*)gid Block:(UpdateGroupCompletion)block;
-(void) clear;

-(void)clearLocalMessage:(NSString*)groupID;
@end





