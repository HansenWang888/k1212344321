//
//  CourseSQL.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDSQLLogManager.h"

@interface WDSQLLogManager ()
@property (nonatomic, copy) NSString *behaviorFilePath;

@end
@implementation WDSQLLogManager

+ (instancetype)sharedSqliteManager {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)openBehaviorLogSQLite {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:WD_BEHAVIOR_LOG_SQL_NAME];

    //实例化数据库队列，会覆盖添加数据库
    self.sqlQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    /*
     private String userID;
     private String lastPageName;
     private String pageName;
     private String widgetName;
     private String operType;
     private Long operateTime;
     private String appID;
     private String appVersion;
     private String endInfo;
     private String endOs;
     */
    [self createTableName:WD_BEHAVIOR_LOG_SQL_TABLENAME parameters:@[
                                                                     @"id TEXT NOT NULL,\n",
                                                                @"userID TEXT NOT NULL,\n",
                                                                @"lastPageName TEXT NOT NULL,\n",
                                                                @"pageName TEXT NOT NULL,\n",
                                                                @"widgetName TEXT NOT NULL,\n",
                                                                @"operType TEXT NOT NULL,\n",
                                                                @"operateTime TEXT NOT NULL,\n",
                                                                @"appID TEXT NOT NULL,\n",
                                                              @"appVersion TEXT NOT NULL,\n",
                                                              @"endInfo TEXT NOT NULL,\n",
                                                              @"endOS TEXT NOT NULL\n",
                                                                @");"
                                                              ]];
}
//创表
- (void)createTableName:(NSString *)tableName parameters:(NSArray *)parameters {
    NSMutableString *insturctM = [NSMutableString stringWithString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(\n",tableName]];
    for (NSString *str in parameters) {
        [insturctM appendString:str];
    }
    //增删改
    [self.sqlQueue inDatabase:^(FMDatabase *db) {
        //创建数据表
        if ([db executeUpdate:insturctM]) {

        } else {
            WDULog(@"创表%@失败",tableName);
        }
    }];
}
- (NSString *)behaviorPath {
    return self.behaviorFilePath;
}
@end
