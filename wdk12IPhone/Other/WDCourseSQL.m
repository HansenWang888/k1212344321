//
//  WDCourseSQL.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDCourseSQL.h"
#import "WDHTTPManager.h"
#import "WDSQLManager.h"

@implementation WDCourseSQL

//MARK:课表*************/
+ (void)loadCourseWithDateStr:(NSString *)dateStr ID:(NSString *)ID paramKey:(NSString *)key method:(NSString *)method isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *dict))finished {
    //作为数据库的查询ID字符必须全部转为数字才能查到
    NSString *newID = [ID stringByReplacingOccurrencesOfString:@"," withString:@""];

    [self loadCourseForSQLWithDateStr:dateStr ID:newID finished:^(NSDictionary *dict) {
        if (isSQL) {
            if (dict != nil) {
                NSLog(@"数据库加载");
                finished(dict);
                return;
            }
        }
        [[WDHTTPManager sharedHTTPManeger] loadMyCourseListWithID:ID date:dateStr paramKey:key method:method finished:^(NSDictionary *dict) {
            NSLog(@"网络加载");
            //保存到数据库
            if (dict != nil) {
                [self saveCourseToSQL:dict dateStr:dateStr ID:newID];
                finished(dict);
                return ;
            }
            finished(nil);
        }];
    }];
}
//从数据库查找数据
+ (void)loadCourseForSQLWithDateStr:(NSString *)dateStr ID:(NSString *)ID finished:(void (^)(NSDictionary *dict))finished {
    NSString *instruck = [NSString stringWithFormat:@"SELECT requiredID, dateID, courseData FROM %@ \n WHERE requiredID = %@ AND dateID = %@;",TIMETABLE,ID,dateStr];
    [self findDataFormTableWithInstruck:instruck finished:^(NSDictionary *dict) {
        if (dict) {
            finished(dict);
        }else {
            finished(nil);
        }
    }];
}
//将数据保存到数据库
+ (void)saveCourseToSQL:(NSDictionary *)datas dateStr:(NSString *)date ID:(NSString *)ID {
    //语句
    NSString *instruck = [NSString stringWithFormat:@"INSERT INTO %@ (requiredID, dateID, courseData) VALUES (?, ?, ?);",TIMETABLE];
    //将字典转换成二进制
    NSData *data = [NSJSONSerialization dataWithJSONObject:datas options:NSJSONWritingPrettyPrinted error:nil];
    //将二进制转换成字符串
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //将数据保存到数据库
    [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //填充语句和数据插入数据库，如果失败进行回滚
        if (![db executeUpdate:instruck,ID,date,dataStr]) {
            *rollback = YES;
        }
    }];
}
+ (void)findDataFormTableWithInstruck:(NSString *)instruck finished:(void(^)(NSDictionary *))finished {
    [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set = [db executeQuery:instruck];
        if (set == nil) {
            finished(nil);
            return;
        }
        NSDictionary *dict;
        while (set.next) {
            //转换数据
            NSString *str = [set stringForColumn:@"courseData"];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }
        finished(dict);
    }];
}
//MARK:课程**************
+ (void)loadLessonWithparameter:(NSDictionary *)parameter URL:(NSString *)url isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *))finished {
    
    NSString *newID = [parameter[@"bjIDList"] stringByReplacingOccurrencesOfString:@"," withString:@""];
    if (isSQL) {
        [self loadLessonFormSQLWithID:newID startID:parameter[@"startID"] courseCount:parameter[@"ts"] finished:^(NSDictionary *dict) {
            if (dict) {
                finished(dict);
                NSLog(@"数据库加载");
                return ;
            }
            [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
                if (dict) {
                    finished(dict);
                    if (![dict[@"endID"] isEqualToString:@"0"]) {
                        [self saveLessonToTableWithData:dict ID:newID];
                    }
                    NSLog(@"网络加载");
                    return ;
                }
                finished(nil);
            }];
        }];
        return;
    }
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            finished(dict);
            if (![dict[@"endID"] isEqualToString:@"0"]) {
                [self saveLessonToTableWithData:dict ID:newID];
            }
            NSLog(@"网络加载");
            return ;
        }
        finished(nil);
    }];
}
+ (void)loadLessonFormSQLWithID:(NSString *)ID startID:(NSString *)startID courseCount:(NSString *)courseCount finished:(void(^)(NSDictionary *))finished {
    NSMutableString *instruck = [NSMutableString stringWithFormat:@"SELECT courseID, creatTime, classesID, courseData FROM %@ \n WHERE classesID = %@\n",COURSETABLE,ID];
    if (startID.length > 0) {
        NSString *condition = [NSString stringWithFormat:@"SELECT creatTime FROM %@ WHERE courseID = %@",COURSETABLE,startID];
        [instruck appendString:[NSString stringWithFormat:@"AND creatTime < (%@)\n",condition]];
    }
    [instruck appendString:[NSString stringWithFormat:@"ORDER BY creatTime DESC LIMIT %@;",courseCount]];
    [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set = [db executeQuery:instruck];
        if (set == nil) {
            finished(nil);
            return;
        }
        NSMutableArray *arrayM = [NSMutableArray array];
        while (set.next) {
            //转换数据
            NSString *str = [set stringForColumn:@"courseData"];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [arrayM addObject:dict];
        }
        if (arrayM.count > 0) {
            NSDictionary *dict = @{@"endID" : arrayM.lastObject[@"kcID"], @"kcList" : arrayM};
            finished(dict);
            return;
        }
        finished(nil);
    }];
}
//保存课程数据到数据库
+ (void)saveLessonToTableWithData:(NSDictionary *)datas ID:(NSString *)ID {
    
    //在保存前将同样ID的数据删除
    for (NSDictionary *dd in datas[@"kcList"]) {
        NSString *courseID = dd[@"kcID"];
        NSString *dateStr = dd[@"lrsj"];
        NSDate *date = [self dateLocalWithString:dateStr format:@"yyyy-MM-dd HH:mm:ss"];
        NSString *deleInstruck = [NSString stringWithFormat:@"DELETE FROM %@ WHERE courseID = %@ AND creatTime = %@ AND classesID = %@;",COURSETABLE,courseID,date,ID];
        [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if (![db executeUpdate:deleInstruck]) {
                NSLog(@"删除数据失败");
            }
        }];
    }
    NSString *instruck = [NSString stringWithFormat:@"INSERT INTO %@ (courseID, creatTime, classesID, courseData) VALUES (?, ?, ?, ?);",COURSETABLE];
    for (NSDictionary *dict in datas[@"kcList"]) {
        NSString *courseID = dict[@"kcID"];
        NSString *dateStr = dict[@"lrsj"];
        NSDateFormatter *format=[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [format dateFromString:dateStr];
        //将字典转换成二进制
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        //将二进制转换成字符串
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //将数据保存到数据库
        [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            //填充语句和数据插入数据库，如果失败进行回滚
            if (![db executeUpdate:instruck,courseID,date,ID,dataString,nil]) {
                NSLog(@"插入数据失败");
                *rollback = YES;
            }
        }];
    }
}
//MARK:作业
+(void)loadTaskWithparameter:(NSDictionary *)parameter URL:(NSString *)url isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *))finished {
    NSString *newID = [parameter[@"bjID"] stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *startID = parameter[@"startID"];
    //开始日期
    NSDate *startDate;
    __block NSTimeInterval startTime;
    if ([startID isEqualToString:@"0"]) {
        //第一次加载
        startDate = [self dateLocalWithString:parameter[@"endrq"] format:@"yyyyMMdd"];
        startTime = startDate.timeIntervalSinceNow;
    } else {
        //上拉刷新，日期改变
        startDate = [self dateLocalWithString:startID format:@"yyyyMMdd"];
        startTime = startDate.timeIntervalSinceNow;
    }
    //截止日期
    NSDate *endDate = [self dateLocalWithString:parameter[@"startrq"] format:@"yyyyMMdd"];;
     NSTimeInterval endTime = endDate.timeIntervalSinceNow;
    NSString *subjectID = parameter[@"kmID"];
    if ([subjectID isEqualToString:@"all"]) {
        //全部搜索时改为0
        subjectID = @"999";
    } else if ([subjectID isEqualToString:@"other"]) {
        //其他搜索改成1
        subjectID = @"111";
    }
    __block NSDictionary *dataDict;
    while (startTime > endTime && dataDict == nil) {
//        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:startTime];
        [self loadTaskForSQLWithStartID:startID classesID:newID subjectID:subjectID submitStateID:parameter[@"zytjzt"] studentID:parameter[@"xsID"] finished:^(NSDictionary *dict) {
    
            if (dict == nil) {
                startTime -= 60 * 60 * 24;
            } else {
                dataDict = dict;
                NSLog(@"数据库加载---");
                finished(dict);
            }
        }];
    }
    //当从数据搜索完毕还是数据还是为空就从网络加载
    if (dataDict == nil) {
        [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
            if (dict) {
                finished(dict);
                if (![dict[@"endID"] isEqualToString:@"0"]) {
                    [self saveTaskToTableWithData:dict studentID:parameter[@"xsID"]];
                }
                NSLog(@"网络加载--");
                return ;
            }
            finished(nil);
        }];
    }
}
+ (void)loadTaskForSQLWithStartID:(NSString *)startID classesID:(NSString *)classesID subjectID:(NSString *)subjectID submitStateID:(NSString *)stateID studentID:(NSString *)studentID finished:(void(^)(NSDictionary *))finished {
   
    finished(nil);
//    //如果是搜索全部科目时，去掉科目条件
//    NSString *subString = ([subjectID isEqualToString:@"999"]) ? @"" :[NSString stringWithFormat:@"AND subjectID = %@",subjectID];
//    NSMutableString *instruck = [NSMutableString stringWithFormat:@"SELECT classesID, subjectID, submitStateID, taskData, studentID FROM %@ \n WHERE classesID = %@ %@ AND submitStateID = %@ AND studentID = %@\n",COURSETABLE,classesID,subString,stateID,studentID];
//    if (![startID isEqualToString:@"0"]) {
//        NSString *condition = [NSString stringWithFormat:@"SELECT creatTime FROM %@ WHERE courseID = %@",COURSETABLE,startID];
//        [instruck appendString:[NSString stringWithFormat:@"AND creatTime < (%@)\n",condition]];
//    }
//    //一次加载五条
//    [instruck appendString:@"ORDER BY creatTime DESC LIMIT 5;"];
    //以后使用
    {
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyyMMdd";
//    NSString *dateStr = [formatter stringFromDate:date];
//    dateStr = @"20151105";
//    //如果是搜索全部科目时，去掉科目条件
//    NSString *subString = ([subjectID isEqualToString:@"999"]) ? @"" :[NSString stringWithFormat:@"AND subjectID = %@",subjectID];
//    NSMutableString *instruck = [NSMutableString stringWithFormat:@"SELECT creatTime, classesID, taskData, subjectID, submitStateID, studentID FROM %@ \n WHERE creatTime = %@ AND classesID = %@ %@ AND submitStateID = %@ AND studentID = %@;" ,TASKTABLE,dateStr,classesID,subString,stateID,studentID];
//    NSLog(@"查询日期==%@---%f",dateStr,date.timeIntervalSince1970);
//    [[WDSQLManager sharedSqliteManager].sqlQueue inDatabase:^(FMDatabase *db) {
//        FMResultSet *set = [db executeQuery:instruck];
//        if (set == nil) {
//            finished(nil);
//            return;
//        }
//        NSMutableArray *arrayM = [NSMutableArray array];
//        while (set.next) {
//            //转换数据
//            NSString *str = [set stringForColumn:@"taskData"];
//            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//            [arrayM addObject:dict];
//        }
//        if (arrayM.count > 0) {
//            //返回endID
//            NSString *dateStr = arrayM.lastObject[@"fbrq"];
//            dateStr = [dateStr substringToIndex:10];
//            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = @"yyyyMMdd";
//            NSDate *endDate = [self dateLocalWithString:dateStr format:@"yyyyMMdd"];
//            NSString *endID = [formatter stringFromDate:endDate];
//            NSDictionary *dict = @{@"endID" : endID, @"zyList" : arrayM};
//            finished(dict);
//            return;
//        }
//        finished(nil);
//    }];
    }
}
+ (void)saveTaskToTableWithData:(NSDictionary *)datas studentID:(NSString *)studentID {
   
    NSString *instruck = [NSString stringWithFormat:@"INSERT INTO %@ (creatTime, classesID, taskData, subjectID, submitStateID, studentID) VALUES (?, ?, ?, ? ,? ,?);",TASKTABLE];
    for (NSDictionary *dict in datas[@"zyList"]) {
        NSString *dateStr = dict[@"fbrq"];
        //截取年月日
        dateStr = [dateStr substringToIndex:10];
        NSString *subjectID = dict[@"km"];
        if ([subjectID isEqualToString:@"other"]) {
            //其他科目搜索改成111
            subjectID = @"111";
        }
        NSString *submitStateID = dict[@"tjzt"];
        NSString *classesID = dict[@"bjID"];
        NSDate *localeDate = [self dateLocalWithString:dateStr format:@"yyyy-MM-dd"];
        NSLog(@"保存的日期==%@",localeDate);
        //将字典转换成二进制
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        //将二进制转换成字符串
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //将数据保存到数据库
        [[WDSQLManager sharedSqliteManager].sqlQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            db.dateFormat = [FMDatabase storeableDateFormat:@"yyyy-MM-dd"];
            //填充语句和数据插入数据库，如果失败进行回滚
            if (![db executeUpdate:instruck,localeDate,classesID,dataString,subjectID,submitStateID,studentID]) {
                NSLog(@"插入数据失败");
                *rollback = YES;
            }
            NSLog(@"插入数据成功！");
        }];
    }
}
//将字符串转换成时间
+ (NSDate *)dateLocalWithString:(NSString *)dateStr format:(NSString *)format {
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *creatTime = [formatter dateFromString:dateStr];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:creatTime];
    NSDate *localeDate = [creatTime dateByAddingTimeInterval:interval];
    return localeDate;
}
@end
