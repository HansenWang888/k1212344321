//
//  DDLoginManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDHttpServer,DDMsgServer,DDTcpServer,DDUserEntity;
typedef NS_ENUM(NSInteger,LoginState){
    LoginStateLoginIng = 0,
    LoginStateLoginSuccess = 1,
    LoginStateLoginFailure = 2
};
@interface LoginModule : NSObject
{
    DDHttpServer* _httpServer;
    DDMsgServer* _msgServer;
    DDTcpServer* _tcpServer;
}

@property (nonatomic,readonly)NSString* token;
+ (instancetype)instance;
@property (nonatomic) LoginState loginState;
-(BOOL)isLogining;
-(void)setisLogining:(BOOL)v;
/**
 *  登录接口，整个登录流程
 *
 *  @param name     用户名
 *  @param password 密码
 */
- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(DDUserEntity* user))success failure:(void(^)(NSString* error))failure;

-(void)offlineLogin:(NSString*)name UID:(NSString*)uid success:(void(^)(DDUserEntity* user))success failure:(void(^)(NSString* error))failure;
-(void)setLoginUname:(NSString*)uname;


- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure;
@end
