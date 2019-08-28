//
//  DDUserModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserEntity.h"

typedef void(^DDLoadRecentUsersCompletion)();
typedef void(^LoadAllUsersCompletion)();

@interface DDUserModule : NSObject


+ (instancetype)shareInstance;
- (void)addMaintanceUser:(DDUserEntity*)user;
-(void)LoadAllUser:(LoadAllUsersCompletion)block;
- (void )getUserForUserID:(NSString*)userID Block:(void(^)(DDUserEntity *user))block;
-(DDUserEntity*)getUserByID:(NSString*)userID;


-(NSArray *)getAllMaintanceUser;
-(void)clear;
-(void)clearLocalMessage:(NSString*)userID;
@end
