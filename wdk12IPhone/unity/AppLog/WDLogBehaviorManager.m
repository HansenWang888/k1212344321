//
//  WDLogBehaviorManager.m
//  行为日志
//
//  Created by 老船长 on 2017/5/16.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import "WDLogBehaviorManager.h"
#import <UIKit/UIKit.h>
#import "WDSQLLogManager.h"
#import "WDLogBehavior.h"
#import <objc/runtime.h>
#import "WDLogBehavior.h"

typedef enum {
    WDUploadLogTypeApp,
    WDUploadLogTypeError,
    WDUploadLogTypeUser
} WDUploadLogType;
@interface WDLogBehaviorManager ()
@property (assign, nonatomic) WDUploadLogType logType;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *submitLogs;
@property (nonatomic, strong) NSTimer *behaviorTimer;
@property (assign, nonatomic) long long time;
@property (assign, nonatomic) BOOL isUploading;

@end
#define BehaviorLog_upload_interval @"BehaviorLog_upload_interval"
NSString *currentPageName = nil;
NSString *currentWidgetName = nil;
static WDLogBehaviorManager *manager = nil;
@implementation WDLogBehaviorManager
+ (instancetype)logManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WDLogBehaviorManager new];
        manager.time = 300;
        manager.submitLogs = @[].mutableCopy;
        [manager.behaviorTimer fire];
    });
    return manager;
}

+ (void)saveLogToSQLWithLogger:(WDLogBehavior *)logger {
    
    //语句
    NSString *instruck = [NSString stringWithFormat:@"INSERT INTO %@ (id,userID,lastPageName,pageName,widgetName,operType,operateTime,appID,appVersion,endInfo,endOs) VALUES (?,?,?,?,?,?,?,?,?,?,?);",WD_BEHAVIOR_LOG_SQL_TABLENAME];
    //将数据保存到数据库
    [[WDSQLLogManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *allNum = [db stringForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",WD_BEHAVIOR_LOG_SQL_TABLENAME]];
        logger.id = [NSString stringWithFormat:@"%ld",[allNum integerValue] + 1];
        //填充语句和数据插入数据库，如果失败进行回滚
        if (![db executeUpdate:instruck,logger.id,logger.userID,logger.lastPageName,logger.pageName,logger.widgetName,logger.operType,logger.operateTime,logger.appID,logger.appVersion,logger.endInfo,logger.endOs]) {
            *rollback = YES;
        }
        
    }];
}
+ (void)deleteLogSQlite {
    NSString *instruck = [NSString stringWithFormat:@"delete from %@;",WD_BEHAVIOR_LOG_SQL_TABLENAME];
    
    [[WDSQLLogManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:instruck];
        if (isSuccess) {
            
        }
    }];
}

+ (void)uploadLoggerFinished:(void (^)(BOOL))finished {
    if (manager.isUploading) {
        if (finished) {
            finished(YES);
        }
        return;
    }
    NSString *instruck = [NSString stringWithFormat:@"SELECT id,userID,lastPageName,pageName,widgetName,operType,operateTime,appID,appVersion,endInfo,endOs FROM %@",WD_BEHAVIOR_LOG_SQL_TABLENAME];
    [[WDSQLLogManager sharedSqliteManager].sqlQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:instruck];
        if (set == nil) {
            if (finished) {
                finished(YES);
            }
            return;
        }
        NSMutableArray *list = @[].mutableCopy;
        while (set.next) {
            WDLogBehavior *logger = [WDLogBehavior new];
            logger.userID = [set stringForColumn:@"userID"];
            logger.lastPageName = [set stringForColumn:@"lastPageName"];
            logger.pageName = [set stringForColumn:@"pageName"];
            logger.widgetName = [set stringForColumn:@"widgetName"];
            logger.operateTime = [set stringForColumn:@"operateTime"];
            logger.appID = [set stringForColumn:@"appID"];
            logger.appVersion = [set stringForColumn:@"appVersion"];
            logger.endInfo = [set stringForColumn:@"endInfo"];
            logger.endOs = [set stringForColumn:@"endOs"];
            logger.operType = [set stringForColumn:@"operType"];
            logger.id = [set stringForColumn:@"id"];
            [[WDLogBehaviorManager logManager].submitLogs addObject:logger];
            NSDictionary *dict = @{
                                   @"appID":logger.appID,
                                   @"userID":logger.userID,
                                   @"lastPageName":logger.lastPageName,
                                   @"pageName":logger.pageName,
                                   @"widgetName":logger.widgetName,
                                   @"operType":logger.operType,
                                   @"operateTime":logger.operateTime,
                                   @"appVersion":logger.appVersion,
                                   @"endInfo":logger.endInfo,
                                   @"endOs":logger.endOs
                                   };
            
            [list addObject:dict];
        }
        if (list.count > 0) {
            NSDictionary *parameter = @{@"behaviorLogList":list.copy};
            [[WDLogBehaviorManager logManager] submitBehaviorLogWithParameter:parameter finished:finished];
            manager.isUploading = YES;
        } else {
            if (finished) {
                finished(YES);
            }
        }
    }];
}
- (void)timerUploadLog {
    [WDLogBehaviorManager uploadLoggerFinished:nil];
}
- (void)submitBehaviorLogWithParameter:(NSDictionary *)pamameter finished:(void(^)(BOOL))finished {
    NSString *url = [NSString stringWithFormat:@"http://192.168.6.104/uploadBehaviorLog"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:pamameter options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpRsp = response;
        manager.isUploading = NO;
        if(httpRsp.statusCode == 200) {
            NSError* jerr = nil;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jerr];
            if(jerr) {
                WDULog(@"上传行为日志失败！原因 = %@",jerr);
                if (finished) {
                    finished(NO);
                }
                
            } else{
                WDULog(@"上传行为日志成功！");
                [manager.submitLogs enumerateObjectsUsingBlock:^(WDLogBehavior  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [manager deleteWithID:obj.id];
                }];
                [manager.submitLogs removeAllObjects];
                if (finished) {
                    finished(YES);
                }
                NSString *interval = [dic[@"data"] objectForKey:@"interval"];
                interval = [NSString stringWithFormat:@"%lld", [interval longLongValue] / 1000];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:interval forKey:BehaviorLog_upload_interval];
                if (interval.longLongValue != manager.time) {
                    [manager.behaviorTimer invalidate];
                    manager.behaviorTimer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [manager.behaviorTimer fire];
                    });
                }
            }
        } else {
            if (finished) {
                finished(NO);
            }
            WDULog(@"上传行为日志失败！原因 = %@",error);
        }
    }];
    [task resume];
}
- (void)deleteWithID:(NSString *)Id {
    NSString *instruck = [NSString stringWithFormat:@"delete from %@  where id = %@",WD_BEHAVIOR_LOG_SQL_TABLENAME,Id];
    [[WDSQLLogManager sharedSqliteManager].sqlQueue inDatabase:^(FMDatabase *db) {
       BOOL isSuccess = [db executeUpdate:instruck];
        if (isSuccess) {
        }
    }];
}
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *con = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:con delegate:nil delegateQueue:nil];
    }
    return _session;
}
- (NSTimer *)behaviorTimer {
    if (!_behaviorTimer) {
        NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
        NSString *time = [defaluts objectForKey:BehaviorLog_upload_interval];
        if (time) {
            manager.time = time.longLongValue;
        }
        _behaviorTimer = [NSTimer scheduledTimerWithTimeInterval:manager.time target:self selector:@selector(timerUploadLog) userInfo:nil repeats:YES];
    }
    return _behaviorTimer;
}

@end
@implementation UIViewController (delegateShow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //dimissVC
        SEL originalDismissSelector = @selector(viewDidDisappear:);
        SEL swizzledDismissSelector = @selector(swiz_viewDidDisappear:);
        [self swizzlingInClass:[self class] originalSelector:originalDismissSelector swizzledSelector:swizzledDismissSelector];
        //didShow
        SEL originalDidSelector = @selector(viewDidAppear:);
        SEL swizzledDidSelector = @selector(swiz_viewDidAppear:);
        [self swizzlingInClass:[self class] originalSelector:originalDidSelector swizzledSelector:swizzledDidSelector];
    });
}
+ (void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = cls;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)swiz_viewDidDisappear:(BOOL)animated {
    [self swiz_viewDidDisappear:animated];
    NSString *disClassVC = NSStringFromClass(self.class);
    if (![self filtrationVC]) {
        NSString *creatTime = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970 * 1000];
        WDLogBehavior *behavior = [WDLogBehavior createLogger];
        behavior.pageName = disClassVC;
        behavior.type = OperationTypeOut;
        behavior.operateTime = creatTime;
        if (currentWidgetName.length > 0) {
            behavior.widgetName = currentWidgetName;
            currentWidgetName = nil;
        }
        [WDLogBehaviorManager saveLogToSQLWithLogger:behavior];
    }
}
//过滤掉不想记录的控制器
- (BOOL)filtrationVC {
    NSString *classStr = NSStringFromClass(self.class);
    classStr = [classStr substringWithRange:NSMakeRange(0, 2)];
    if ([self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UITabBarController class]] || [classStr isEqualToString:@"UI"]) {
        NSLog(@"--------%@",self);
        return YES;
    }
    return NO;
}
- (void)swiz_viewDidAppear:(BOOL)animated {
    [self swiz_viewDidAppear:animated];
    if (![self filtrationVC]) {
        NSString *showClassVC = NSStringFromClass(self.class);
        NSString *creatTime = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970 * 1000];
        WDLogBehavior *behavior = [WDLogBehavior createLogger];
        behavior.pageName = showClassVC;
        behavior.type = OperationTypeIn;
        behavior.operateTime = creatTime;
        if (currentPageName.length > 0) {
            behavior.lastPageName = currentPageName;
        }
        if (currentWidgetName.length > 0) {
            behavior.widgetName = currentWidgetName;
            currentWidgetName = nil;
        }
        [WDLogBehaviorManager saveLogToSQLWithLogger:behavior];
        currentPageName = showClassVC;
    }
}
@end
@implementation UIControl (StatisticClick)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL swizzledSelector = @selector(swiz_sendAction:to:forEvent:);
        [self swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}
+ (void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Class class = cls;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
#pragma mark - Method Swizzling
- (void)swiz_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    //执行记录操作
    NSString *className = NSStringFromClass(self.class);
    currentWidgetName = className;
    //这里就是调用原来的方法sendAction了
    [self swiz_sendAction:action to:target forEvent:event];
}
@end
