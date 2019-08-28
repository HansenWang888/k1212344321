#ifndef _COUTACT_MOUDLE_H_
#define _COUTACT_MOUDLE_H_

#import <Foundation/Foundation.h>



#import "IMBaseDefine.pb.h"

@class VerifyEntity;
@class DDUserEntity;
@class GroupEntity;

typedef void(^ContactModifyCompeletion)(NSError*);
typedef void(^UsersInfoCompeletion)(NSError* error,NSArray* userlist);
typedef void(^UserInfoCompeletion)(NSError* error,DDUserEntity* user);
typedef void(^ContactLoadCompeletion)();
typedef void (^SearchUserCompeletion)(NSMutableArray*,NSMutableArray*);
typedef void(^VerifyListCompeletion)(NSError* error,NSArray* verifies);

typedef void(^ModifySelfCompeletion)(NSError* error,NSInteger responetime);

@interface ContactModule : NSObject
+ (instancetype)shareInstance;


-(void)registerNotify;

-(void)LoadContact:(ContactLoadCompeletion)block;
-(void)refreshContact;


-(BOOL)IsContactUser:(NSString*)uid;
-(BOOL)IsContactGroup:(NSString*)gid;
-(NSMutableDictionary*)GetContact;
-(NSMutableArray*)GetContactUser;
-(NSMutableArray*)GetContactGroup;
-(ContactInfoEntity*)GetContactInfoByID:(NSString*)objid;

-(void)SearchUser:(NSString*)key Block:(SearchUserCompeletion)block;
-(void)removeUserFromContact:(NSString*) uid Block:(ContactModifyCompeletion) block;
-(void)addUserToContact:(NSString*)uid Block:(ContactModifyCompeletion)block;
-(void)removeGroupFromContact:(NSString*) gid Block:(ContactModifyCompeletion) block;
-(void)addGroupToContact:(NSString*)gid Block:(ContactModifyCompeletion)block;
-(void)modifyRmkname:(NSString*)uid Value:(NSString*)value Block:(ContactModifyCompeletion)block;

//-(void) GetUsersInfoFromServer:(NSArray*) lsuid ColCount:(NSInteger)colcount Block: (UsersInfoCompeletion)block;
-(void)GetUsersInfoFromServer:(NSArray *)lsuid Block:(UsersInfoCompeletion)block;
#pragma mark verify
-(void)addFrindVerify:(NSString*)uid Verify:(NSString*)verify Block:(ContactModifyCompeletion)block;
-(void)refreshFriendVerify;
-(NSArray*)getAllVerify;
- (VerifyEntity *)getVerifyWithVerifyID:(NSString *)verifyID;
-(void)acceptFriendVerify:(VerifyEntity*)ventity Block:(ContactModifyCompeletion)block;
-(void)denialFriendVerify:(VerifyEntity*)ventity Block:(ContactModifyCompeletion)block;

#pragma mark tools
-(void)clear;

-(DDUserEntity*)getUserInfoWithNotification:(NSString *)uid ForUpdate:(BOOL)update;
-(void)getGroupMembersFromServerWithNotify:(GroupEntity*)gentity ;


#pragma mark theruntimeuser
-(void)updateAvatar:(NSString*)fileID;
-(void)updatePS:(NSString*)ps;
@end









#endif
