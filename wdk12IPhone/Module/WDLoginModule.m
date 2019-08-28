 //
//  WDLoginModule.m
//  wdk12IPhone
//
//  Created by macapp on 15/9/26.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDLoginModule.h"
#import "WDHTTPManager.h"
#import "WDUser.h"
#import "IMInterFace.h"

@interface WDLoginModule ()

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) NSDictionary *firstDict;

@end

@implementation WDLoginModule
+(instancetype)shareInstance{
    static WDLoginModule* g_Module;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_Module = [[WDLoginModule alloc] init];
    });
    return g_Module;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(BOOL)couldAutoLogin{
    NSUserDefaults* userdefaults = [NSUserDefaults standardUserDefaults];
    BOOL autologin = [userdefaults objectForKey:@"autologin"] != nil;
    return autologin;
}
-(void)ClearUserDefaults{
     NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:LATEST_LOGIN_PASSWORD];
    [user removeObjectForKey:AUTO_LOGIN];
    [user synchronize];
}
-(void)Login:(NSString*)account Password:(NSString*)password UserType:(NSString*)userType Success:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure{
    
    [[WDHTTPManager sharedHTTPManeger] verifyLoginWithAccount:account password:password finished:^(NSDictionary *dict) {
        dict = [dict nullToStringWithDict:dict];
        NSError* login_error = nil;
        if(!dict) {
            [self removeLocationAddress];
            login_error = [[NSError alloc]initWithDomain:@"dict == nil" code:ERROR_CODE_LOGIN_ERROR userInfo:nil];
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            failure(login_error);
            return ;
        };
        if (![dict[@"result"] intValue]) {
            [self ClearUserDefaults];
            [self removeLocationAddress];
            login_error = [[NSError alloc]initWithDomain:@"result == 0" code:ERROR_CODE_LOGIN_VERIFY_FAILD userInfo:nil];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"账号密码错误", nil)];
            failure(login_error);
            return ;
        }
        NSArray* usertypes = [dict[@"usertype"] componentsSeparatedByString:@","];
        if(![usertypes containsObject:userType]){
            [self ClearUserDefaults];
            [self removeLocationAddress];
            login_error = [[NSError alloc]initWithDomain:@"user type not contain" code:ERROR_CODE_LOGIN_VERIFY_FAILD userInfo:nil];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"登录用户不是教师", nil)];
            failure(login_error);
            return ;
        }
        [[WDHTTPManager sharedHTTPManeger] loginIDWithUserInfo:dict[@"loginid"] userType:dict[@"usertype"]  finished:^(NSDictionary * ruledic) {
            NSError* rule_error = nil;
            NSMutableDictionary *ret = nil;
            if(ruledic == nil) {
                [self removeLocationAddress];
                rule_error = [[NSError alloc]initWithDomain:@"ruledict == nil" code:ERROR_CODE_RULE_ERROR userInfo:nil];
                [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
                failure(rule_error);
                return ;
            }
            ret = [[NSMutableDictionary alloc]initWithDictionary:ruledic];
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [ret setObject:obj forKeyedSubscript:key];
            }];
            ret = [NSDictionary mutableDictWith:ret];
            if([WDUser createInstance:userType Dic:ret] == nil){
                [self removeLocationAddress];
                rule_error = [[NSError alloc]initWithDomain:@"WDUser createInstance == nil" code:ERROR_CODE_RULE_ERROR userInfo:nil];
                [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
                failure(rule_error);
                return;
            }
            [SVProgressHUD dismiss];
            //嵌套数据可能有空值 针对行的修改下
            NSArray * oldList = [ret objectForKey:@"jsjsxxList"];
            NSMutableArray * newList = [[NSMutableArray alloc]init];
            for (NSDictionary * dic in oldList) {

                NSMutableDictionary * newDic = [[NSMutableDictionary alloc]init];
                if ([[dic objectForKey:@"km"]isKindOfClass:[NSNull class]]) {
                    [newDic setValue:@"" forKey:@"km"];
                }else{
                    [newDic setValue:[dic objectForKey:@"km"] forKey:@"km"];
                }
                [newDic setValue:[dic objectForKey:@"bjList"] forKey:@"bjList"];
                [newDic setValue:[dic objectForKey:@"jsjs"] forKey:@"jsjs"];
                
                [newList addObject:newDic];
            }
            [ret setValue:newList forKey:@"jsjsxxList"];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:account forKey:LATEST_LOGIN_ACCOUNT];
            [user setObject:password forKey:LATEST_LOGIN_PASSWORD];
            [user setObject:userType forKey:LATEST_LOGIN_USERTYPE];
            [user setObject: ret forKey:LATEST_USER];
            [user setBool:YES forKey:AUTO_LOGIN ];
            [user synchronize];
            success();
            IM_Login();

        }];
    }];
}


//第一步登录 账号密码 用户类型
- (void)firstStepLoginAccount:(NSString*)account Password:(NSString*)password UserType:(NSString*)userType Success:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure {
    
    [WDLoginModule shareInstance].account  = account;
    [WDLoginModule shareInstance].password = password;
    [WDLoginModule shareInstance].userType = userType;
    
    [[WDHTTPManager sharedHTTPManeger] verifyLoginWithAccount:account password:password finished:^(NSDictionary *dict) {
        
#pragma mark 第一步登录失败
        
        dict = [dict nullToStringWithDict:dict];
        NSError* login_error = nil;
        if(!dict) {
            [self removeLocationAddress];
            login_error = [[NSError alloc]initWithDomain:@"dict == nil" code:ERROR_CODE_LOGIN_ERROR userInfo:nil];
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            failure(login_error);
            return ;
        };
        if (![dict[@"result"] intValue]) {
            [self removeLocationAddress];
            [self ClearUserDefaults];
            login_error = [[NSError alloc]initWithDomain:@"result == 0" code:ERROR_CODE_LOGIN_VERIFY_FAILD userInfo:nil];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"账号密码错误", nil)];
            failure(login_error);
            return ;
        }
        NSArray* usertypes = [dict[@"usertype"] componentsSeparatedByString:@","];
        if(![usertypes containsObject:userType]){
            [self removeLocationAddress];
            [self ClearUserDefaults];
            login_error = [[NSError alloc]initWithDomain:@"user type not contain" code:ERROR_CODE_LOGIN_VERIFY_FAILD userInfo:nil];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"登录用户不是教师", nil)];
            failure(login_error);
            return ;
        }
        
#pragma mark 第一步登录成功
        [WDLoginModule shareInstance].firstDict = dict;

        //本地location
        NSString *user_Location = [[NSUserDefaults standardUserDefaults] objectForKey:User_Location_Key];
        
        //同一个用户已经请求过location 假如有服务器地址 不在请求
        if (user_Location && [user_Location hasPrefix:dict[@"id"]]) {
            //本地服务器地址
            NSDictionary *address = [[NSUserDefaults standardUserDefaults] objectForKey:User_Server_Address_Key];
            
            if (address) {//有服务器地址
                BOOL isSuccess = [ServerManager setServerAddressWith:address];//设置地址
                
                if (isSuccess) {
                    [self getUserInfonSuccess:success Failure:failure];//走第四步 请求用户信息
                }else {
                    [self secondStepLoginSuccess:success Failure:failure];//走第二步
                }
            }else {
                [self secondStepLoginSuccess:success Failure:failure];//走第二步
            }
        }else {
            [self secondStepLoginSuccess:success Failure:failure];//走第二步
        }
    }];
}

//第二步登录 获取区域代码
- (void)secondStepLoginSuccess:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure {

    NSDictionary *temDic = @{
                             @"userType":[WDLoginModule shareInstance].userType,
                             @"loginId":[WDLoginModule shareInstance].firstDict[@"loginid"],
                             };
    NSString *urlStr = [NSString stringWithFormat:@"%@/fetchUserOrgInfoByLoginID",REGION_URL];

    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:temDic urlString:urlStr finished:^(NSDictionary *dict) {
        if (dict && dict[@"location"]) {
            
            NSString *location = dict[@"location"];//请求得到的location
            NSString *multLocation = [[WDLoginModule shareInstance].firstDict[@"id"] stringByAppendingString:location];
            [[NSUserDefaults standardUserDefaults] setObject:multLocation forKey:User_Location_Key];
            [[NSUserDefaults standardUserDefaults] setObject:location forKey:Location_Key];
            
            [self thirdStepLoginAppID:Server_AppID location:dict[@"location"] version:@"90" Success:success Failure:failure];
        }else {
            [self removeLocationAddress];
            failure(nil);
        }
    }];
}

//第三步登录 获取服务地址

- (void)thirdStepLoginAppID:(NSString *)appID location:(NSString *)location version:(NSString *)version Success:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure{
    NSDictionary *temDic = @{
                             @"appID":appID,
                             @"location":location,
                             @"version":version,
                             };
    NSString *urlStr = [NSString stringWithFormat:@"%@/fw!getFWDZList.action",SERVER_ADDRESS_URL];
    
    [[WDHTTPManager sharedHTTPManeger] postHTTPSWithParameterDict:temDic urlString:urlStr contentType:@"application/json" finished:^(NSDictionary *dict) {
        if (dict) {
            if (dict[@"data"]) {
                NSDictionary *temDict = dict[@"data"];

                if (temDict) {
                    BOOL isSuccess = [ServerManager setServerAddressWith:temDict];
                    
                    if (isSuccess) {
                        [[NSUserDefaults standardUserDefaults] setObject:temDict forKey:User_Server_Address_Key];
                        [self getUserInfonSuccess:success Failure:failure];
                    }else {
                        [self removeLocationAddress];
                        failure(nil);
                    }
                }
            }else {
                [self removeLocationAddress];
                failure(nil);
            }
        }else {
            [self removeLocationAddress];
            failure(nil);
        }
    }];
}

//第四步登录 获取用户信息
- (void)getUserInfonSuccess:(LoginSuccessBlock)success  Failure:(LoginFaildBlock)failure {
    
    [[WDHTTPManager sharedHTTPManeger] loginIDWithUserInfo:[WDLoginModule shareInstance].firstDict[@"loginid"] userType:[WDLoginModule shareInstance].userType  finished:^(NSDictionary * ruledic) {
        NSError* rule_error = nil;
        NSMutableDictionary *ret = nil;
        if(ruledic == nil) {
            [self removeLocationAddress];
            rule_error = [[NSError alloc]initWithDomain:@"ruledict == nil" code:ERROR_CODE_RULE_ERROR userInfo:nil];
            failure(rule_error);
            return ;
        }
        ret = [[NSMutableDictionary alloc]initWithDictionary:ruledic];
        NSDictionary *dict = [WDLoginModule shareInstance].firstDict;
        
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [ret setObject:obj forKeyedSubscript:key];
        }];
        ret = [NSDictionary mutableDictWith:ret];
        if([WDUser createInstance:[WDLoginModule shareInstance].userType Dic:ret] == nil){
            [self removeLocationAddress];
            rule_error = [[NSError alloc]initWithDomain:@"WDUser createInstance == nil" code:ERROR_CODE_RULE_ERROR userInfo:nil];
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            failure(rule_error);
            return;
        }
        [SVProgressHUD dismiss];
        //嵌套数据可能有空值 针对行的修改下
        NSArray * oldList = [ret objectForKey:@"jsjsxxList"];
        NSMutableArray * newList = [[NSMutableArray alloc]init];
        for (NSDictionary * dic in oldList) {
            
            NSMutableDictionary * newDic = [[NSMutableDictionary alloc]init];
            if ([[dic objectForKey:@"km"]isKindOfClass:[NSNull class]]) {
                [newDic setValue:@"" forKey:@"km"];
            }else{
                [newDic setValue:[dic objectForKey:@"km"] forKey:@"km"];
            }
            [newDic setValue:[dic objectForKey:@"bjList"] forKey:@"bjList"];
            [newDic setValue:[dic objectForKey:@"jsjs"] forKey:@"jsjs"];
            
            [newList addObject:newDic];
        }
        [ret setValue:newList forKey:@"jsjsxxList"];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:[WDLoginModule shareInstance].account forKey:LATEST_LOGIN_ACCOUNT];
        [user setObject:[WDLoginModule shareInstance].password forKey:LATEST_LOGIN_PASSWORD];
        [user setObject:[WDLoginModule shareInstance].userType forKey:LATEST_LOGIN_USERTYPE];
        [user setObject: ret forKey:LATEST_USER];
        [user setBool:YES forKey:AUTO_LOGIN ];
        [user synchronize];
        success();
        IM_Login();
    }];
}

- (void)removeLocationAddress {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Server_Address_Key];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Location_Key];
}

-(void)AutoLogin:(LoginSuccessBlock) success Failure:(LoginFaildBlock)failure Interrupt:(AutoLoginInterrupt)interp{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL autologin = [[user objectForKey:AUTO_LOGIN]boolValue];
    NSString* account = [user objectForKey:LATEST_LOGIN_ACCOUNT];
    NSString* password = [user objectForKey:LATEST_LOGIN_PASSWORD];
    NSString* usertype = [user objectForKey:LATEST_LOGIN_USERTYPE];
    NSDictionary* dic = [user objectForKey:LATEST_USER];

    //autologin = NO;
    if(autologin && account && password && usertype && dic && [WDUser createInstance:usertype Dic:dic]){

        success();
    }
    else{

        NSError* auto_login_faild = [NSError errorWithDomain:@"" code:ERROR_CODE_LOGIN_ERROR userInfo:nil];
        failure(auto_login_faild);
        return;
    }
    
    if (Location) {
        [self firstStepLoginAccount:account Password:password UserType:usertype Success:^{
            success();
        } Failure:^(NSError *error) {
            if(error.code == ERROR_CODE_LOGIN_VERIFY_FAILD){
                
                [self ClearUserDefaults];
                [self removeLocationAddress];
                interp(error);
            }
        }];
    }else {
        [self Login:account Password:password UserType:usertype Success:^{
            success();
        } Failure:^(NSError * error) {
            if(error.code == ERROR_CODE_LOGIN_VERIFY_FAILD){
                
                [self ClearUserDefaults];
                [self removeLocationAddress];
                interp(error);
            }
        }];
    }
}
-(void)GetLatestLogin:(NSString**)account Password:(NSString**)password UserType:(NSString**)userType iconStr:(NSString **)iconStr {
    NSUserDefaults* userdefaults = [NSUserDefaults standardUserDefaults];
    *account = [userdefaults  objectForKey:LATEST_LOGIN_ACCOUNT];
    
    *password = [userdefaults  objectForKey:LATEST_LOGIN_PASSWORD];
    *userType = [userdefaults  objectForKey:LATEST_LOGIN_USERTYPE];
    *iconStr = nil;
    
}
-(void)LogOut{
    [self ClearUserDefaults];
    IM_Logout();
}
@end
