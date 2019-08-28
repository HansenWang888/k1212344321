//
//  WDCourseSQL.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCourseSQL : NSObject
//获取课表
+ (void)loadCourseWithDateStr:(NSString *)dateStr ID:(NSString *)ID paramKey:(NSString *)key method:(NSString *)method isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *))finished;
//获取课程
+ (void)loadLessonWithparameter:(NSDictionary *)parameter URL:(NSString *)url isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *))finished;
//获取作业
+ (void)loadTaskWithparameter:(NSDictionary *)parameter URL:(NSString *)url isSQL:(BOOL)isSQL finished:(void (^)(NSDictionary *))finished;

@end
