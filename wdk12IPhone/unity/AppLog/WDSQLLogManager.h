//
//  CourseSQL.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define WD_BEHAVIOR_LOG_SQL_NAME @"wdbehaviorlog.db"
#define WD_BEHAVIOR_LOG_SQL_TABLENAME @"pageBehavior"

@interface WDSQLLogManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *sqlQueue;//数据库队列
+ (instancetype)sharedSqliteManager;
/**
 *  打开行为日志数据库
 */
//程序日志数据库
- (void)openBehaviorLogSQLite;

@end
