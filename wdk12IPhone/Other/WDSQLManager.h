//
//  CourseSQL.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
static NSString *COURSETABLE = @"WD_courseSQL";//课程
static NSString *TIMETABLE = @"WD_timetableSQL";//课表
static NSString *TASKTABLE = @"WD_taskSQL";//作业
@interface WDSQLManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *sqlQueue;//数据库队列
/**
 *  打开数据库
 */
- (void)openCourseSQLiteWithSqlName:(NSString *)sqlName;
+ (instancetype)sharedSqliteManager;
@end
