//
//  CourseSQL.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDSQLManager.h"

@implementation WDSQLManager

+ (instancetype)sharedSqliteManager {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)openCourseSQLiteWithSqlName:(NSString *)sqlName {
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:sqlName];
    //实例化数据库队列，会覆盖添加数据库
    self.sqlQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    NSLog(@"%@",path);
    //创建课表使用表
    [self createCourseTableWithTableName:TIMETABLE parameters:@[@"requiredID INTEGER NOT NULL,\n",@"dateID INTEGER NOT NULL,\n",@"courseData TEXT NOT NULL",@");"]];
    //创建课程使用表
    [self createCourseTableWithTableName:COURSETABLE parameters:@[@"courseID INTEGER NOT NULL,\n",@"creatTime DATETIME NOT NULL,\n",@"classesID INTEGER NOT NULL,\n",@"courseData TEXT NOT NULL",@");"]];
    //创建作业使用表, 查询是是根据日期来进行搜索的
    [self createCourseTableWithTableName:TASKTABLE parameters:@[@"creatTime DATE NOT NULL,\n",@"classesID INTEGER NOT NULL,\n",@"subjectID INTEGER NOT NULL,\n",@"submitStateID INTEGER NOT NULL,\n",@"studentID INTEGER NOT NULL,\n",@"taskData TEXT NOT NULL",@");"]];
}
//创表
- (void)createCourseTableWithTableName:(NSString *)tableName parameters:(NSArray *)parameters {

    NSMutableString *insturctM = [NSMutableString stringWithString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(\n",tableName]];
    for (NSString *str in parameters) {
        [insturctM appendString:str];
    }
    //增删改
    [self.sqlQueue inDatabase:^(FMDatabase *db) {
        //创建数据表
        if ([db executeUpdate:insturctM]) {
//            NSLog(@"创%@表成功",tableName);
        } else {
//            NSLog(@"创表%@失败",tableName);
        }
    }];
}

@end
