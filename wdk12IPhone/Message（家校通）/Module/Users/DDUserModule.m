//
//  DDUserModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDUserModule.h"
#import "DDDatabaseUtil.h"
@interface DDUserModule(PrivateAPI)

- (void)n_receiveUserLogoutNotification:(NSNotification*)notification;
- (void)n_receiveUserLoginNotification:(NSNotification*)notification;
@end

@implementation DDUserModule
{
    NSMutableDictionary* _allUsers;
}

+ (instancetype)shareInstance
{
    static DDUserModule* g_userModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_userModule = [[DDUserModule alloc] init];
    });
    return g_userModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _allUsers = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void) clear{
    [_allUsers removeAllObjects];
}

- (void)addMaintanceUser:(DDUserEntity*)user
{
    if (!user)
    {
        return;
    }
    [_allUsers setValue:user forKey:user.objID];
    
}
-(void)LoadAllUser:(LoadAllUsersCompletion)block{
    [[DDDatabaseUtil instance]getAllUsers:^(NSArray *contacts, NSError *error) {
        [contacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addMaintanceUser:obj];
        }];
        block();
        
    }];
    
}
-(NSArray *)getAllMaintanceUser
{
    return [_allUsers allValues];
}
- (void )getUserForUserID:(NSString*)userID Block:(void(^)(DDUserEntity *user))block
{
    return block(_allUsers[userID]);
    
}
-(DDUserEntity*)getUserByID:(NSString*)userID{
    
    return _allUsers[userID];
}
-(void)clearLocalMessage:(NSString*)sbID{
    [[DDDatabaseUtil instance]deleteMesagesForSession:sbID completion:^(BOOL success) {
        
    }];
}

#pragma mark -
#pragma mark PrivateAPI




@end
