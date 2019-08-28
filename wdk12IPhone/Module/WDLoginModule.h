//
//  WDLoginModule.h
//  wdk12IPhone
//
//  Created by macapp on 15/9/26.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  void(^LoginSuccessBlock)() ;
typedef  void(^LoginFaildBlock)(NSError*);

typedef LoginFaildBlock AutoLoginInterrupt;

#define ERROR_CODE_LOGIN_ERROR 1
//同一用户验证失败
#define ERROR_CODE_LOGIN_VERIFY_FAILD 2
#define ERROR_CODE_RULE_ERROR 3


#define LATEST_LOGIN_ACCOUNT @"latestLoginAccount"
#define LATEST_LOGIN_PASSWORD @"latestLoginpassword"
#define LATEST_LOGIN_USERTYPE @"latestLoginUserType"
#define AUTO_LOGIN @"autologin"
#define LATEST_USER @"latestuser"
#define USER_ICON_PICTURE @"user_icon_picture"
@interface WDLoginModule : NSObject

+(instancetype)shareInstance;

-(BOOL)couldAutoLogin;

-(void)Login:(NSString*)account Password:(NSString*)password UserType:(NSString*)userType Success:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure;

-(void)AutoLogin:(LoginSuccessBlock) success Failure:(LoginFaildBlock)failure Interrupt:(AutoLoginInterrupt)interp;

-(void)GetLatestLogin:(NSString**)account Password:(NSString**)password UserType:(NSString**)userType iconStr:(NSString **)iconStr;
-(void)LogOut;

#pragma mark --- 从接口获取服务器地址
- (void)firstStepLoginAccount:(NSString*)account Password:(NSString*)password UserType:(NSString*)userType Success:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure;

@end
