//
//  WDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "LoginModule.h"
#import "DDHttpServer.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
//#import "SpellLibrary.h"
#import "DDUserModule.h"
#import "DDUserEntity.h"
#import "DDClientState.h"
#import "RuntimeStatus.h"
#import "ContactModule.h"

#import "DDDatabaseUtil.h"
#import "DDAllUserAPI.h"
#import "LoginAPI.h"
#import "SessionModule.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import "DDClientStateMaintenanceManager.h"
#import "SubscribeModule.h"
#import "WDDNSAnalysis.h"
@interface LoginModule(privateAPI)

- (void)p_loadAfterHttpServerWithToken:(NSString*)token userID:(NSString*)userID dao:(NSString*)dao password:(NSString*)password uname:(NSString*)uname success:(void(^)(DDUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure;
- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure;

@end

@implementation LoginModule
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _dao;
    NSString * _priorIP;
    NSInteger _port;
    BOOL _isLogining;
}
+ (instancetype)instance
{
    static LoginModule *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[LoginModule alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _isLogining = NO;
        _loginState = LoginStateLoginFailure;
    }
    return self;
}


#pragma mark Public API
-(BOOL)isLogining{
    return _isLogining;
}
-(void)setisLogining:(BOOL)v{
    _isLogining = v;
}
-(void)LoadFromLocalDB{
    
    [[DDUserModule shareInstance]LoadAllUser:^{
        
    }];
    [[DDDatabaseUtil instance]loadGroupsCompletion:^(NSArray *contacts, NSError *error) {
        [[DDGroupModule instance]addGroups:contacts];
        
    }];
    
    [[ContactModule shareInstance ]LoadContact:^{
        
    }];
    [[SubscribeModule shareInstance]loadFromDB];
    [[SessionModule sharedInstance]loadLocalSession:^(bool isok) {
        
        [DDNotificationHelp postNotification:DDNotificationLocalPrepared userInfo:nil object:nil];
    }];
}
- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(DDUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure
{
    
    if(self.loginState == LoginStateLoginIng) return ;
    self.loginState = LoginStateLoginIng;
    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationStartLogin object:nil];
    [_httpServer getMsgIp:^(NSDictionary *dic) {
        
        NSInteger code  = [[dic objectForKey:@"code"] integerValue];
        if (code == 0) {
            _priorIP = [dic objectForKey:@"priorIP"];
            _port    =  [[dic objectForKey:@"port"] integerValue];
//            _priorIP = getIPAddressByHostName(_priorIP);
//            TheRuntime.fastdfsdownload = [dic objectForKey:@"fastdfsdownload"];
//            TheRuntime.fastdfsupload = [dic objectForKey:@"fastdfsupload"];
            TheRuntime.fastdfsdownload = FILE_SEVER_DOWNLOAD_URL;
            TheRuntime.fastdfsupload = FILE_SEVER_UNPLOAD_URL;
            [[NSUserDefaults standardUserDefaults]setObject:TheRuntime.fastdfsdownload forKey:@"fastdfsdownload"];
            [[NSUserDefaults standardUserDefaults]setObject:TheRuntime.fastdfsupload forKey:@"fastdfsupload"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tcpServer loginTcpServerIP:_priorIP port:_port Success:^{
                
                [_msgServer checkUserID:name Pwd:password token:@"" success:^(id object) {
                    
                    DDClientState* clientState = [DDClientState shareInstance];
                    
                    DDUserEntity* user = object[@"user"];
                    TheRuntime.user=user;
                     NSString* userkey = [NSString stringWithFormat:@"IM_loginid_%@",name];
                    [[NSUserDefaults standardUserDefaults] setObject:user.objID forKey:userkey];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [[DDDatabaseUtil instance] openCurrentUserDB];
                    [[DDDatabaseUtil instance]insertAllUser:@[user] completion:^(NSError *error) {
                    }];
                    [[DDUserModule shareInstance]addMaintanceUser:user];
                    [[DDUserModule shareInstance]LoadAllUser:^{
                        if(clientState.userState == DDUserOffLineInitiative) [self LoadFromLocalDB];
                        clientState.userState=DDUserOnline;
                        _isLogining = NO;
                        self.loginState = LoginStateLoginSuccess;
                        success(user);
                        [DDNotificationHelp postNotification:DDNotificationUserLoginSuccess userInfo:nil object:user];
                        _lastLoginPassword=password;
                        _lastLoginUserName=name;
                        
                    }];
                  
                } failure:^(id object) {
                    WDULog(@"login#登录验证失败");
                    
                    failure(IMLocalizedString(@"登录验证失败", nil));
                    _isLogining = NO;
                    self.loginState = LoginStateLoginFailure;
                    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginFailure object:nil];
                }];
                
            } failure:^{
                WDULog(@"连接消息服务器失败");
                _isLogining = NO;
                self.loginState = LoginStateLoginFailure;
                failure(IMLocalizedString(@"连接消息服务器失败", nil));
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginFailure object:nil];
            }];
        }
        else{
            _isLogining = NO;
            self.loginState = LoginStateLoginFailure;
            failure(IMLocalizedString(@"获取消息服务器地址失败", nil));
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginFailure object:nil];
        }
    } failure:^(NSString *error) {
        _isLogining = NO;
        self.loginState = LoginStateLoginFailure;
        failure(IMLocalizedString(@"获取消息服务器地址失败", nil));
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginFailure object:nil];
    }];
    
}
-(void)offlineLogin:(NSString*)name UID:(NSString*)uid success:(void(^)(DDUserEntity* user))success failure:(void(^)(NSString* error))failure{
    TheRuntime.user = [[DDUserEntity alloc]initWithUserID:uid];
    [[DDDatabaseUtil instance]openCurrentUserDB];
    //获取所有用户
    [[DDUserModule shareInstance]LoadAllUser:^{
        [[DDUserModule shareInstance]getUserForUserID:uid Block:^(DDUserEntity *user) {
            //测试代码要删的
            if(user) {
                TheRuntime.user = user;
                TheRuntime.fastdfsdownload = [[NSUserDefaults standardUserDefaults] objectForKey:@"fastdfsdownload"];
                TheRuntime.fastdfsupload = [[NSUserDefaults standardUserDefaults] objectForKey:@"fastdfsupload"];
                
                
                _lastLoginUserName = name;
                _lastLoginPassword = @"";
                
                [self LoadFromLocalDB];
                
                success(TheRuntime.user);
                [DDClientStateMaintenanceManager shareInstance];
                [DDClientState shareInstance].userState = DDUserOffLine;
            }
            else{
                [DDClientStateMaintenanceManager shareInstance];
                [DDClientState shareInstance].userState = DDUserOffLineInitiative;
                [self loginWithUsername:name password:uid success:^(DDUserEntity *user) {
                    
                } failure:^(NSString *error) {
                    
                }];
            }
        }];
    }];
    
}
- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure
{
    WDULog(@"relogin fun");
    if ([DDClientState shareInstance].userState == DDUserOffLine && _lastLoginPassword && _lastLoginUserName) {
        
        [self loginWithUsername:_lastLoginUserName password:_lastLoginPassword success:^(DDUserEntity *user) {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloginSuccess" object:nil];
            success(YES);
        } failure:^(NSString *error) {
            failure(error);
        }];
        
    }
}

-(void)setLoginUname:(NSString*)uname{
    _lastLoginUserName = uname;
    _lastLoginPassword = @" ";
}




@end
