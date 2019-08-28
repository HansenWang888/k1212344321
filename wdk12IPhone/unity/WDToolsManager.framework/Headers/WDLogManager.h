//
//  WDExceptionManager.h
//  程序错误管理
//
//  Created by 老船长 on 2017/3/30.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#define  LOG_LEVEL_DEF DDLogLevelDebug
#import <UIKit/UIKit.h>
#define WDEXCEPTIO_NMANAGER [WDLogManager shareManager]
#define WDULog(fmt,...) DDLogInfo(@"[%s-%d]" fmt,__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);
#define UserID_log [WDLogManager shareManager].userID
#define APPID_log [WDLogManager shareManager].appID
@interface WDLogManager : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *logURL;


+ (instancetype)shareManager;
+ (void)initializeAppLog;

+ (void)openLogFileWithVC:(UIViewController *)vc;
- (NSString *)fileDirectory;
//每次登陆成功后调用
+ (void)uploadUserLogFinished:(void(^)(BOOL isSuccess))finished;
//每次程序启动后自动上传
+ (void)uploadExceptionLogFinished:(void(^)(BOOL isSuccess))finished;
//上传行为日志,初始化后 每过五分钟自动上传一次
+ (void)uploadBehaviorLogFinished:(void(^)(BOOL isSuccess))finished;

+ (void)autoUploadUserLog;
+ (BOOL)isWifiStatus;

@end
