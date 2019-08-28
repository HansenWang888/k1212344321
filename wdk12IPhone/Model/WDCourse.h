//
//  WDCourse.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCourse : NSObject

@property (nonatomic, copy) NSString *timeBucket;//时间段
@property (nonatomic, strong) NSMutableArray *courseLists;

+ (instancetype)coureseWithDict:(NSDictionary *)dict;
/**
 *  加载课程信息
 *
 *  @param dateStr  日期
 *  @param ID       老师ID或班级ID
 *  @param key      需要传入的参数key
 *  @param method   获取数据的方法名
 *  @param isSQL    是否从数据库加载
 *  @param finished 回调
 */
- (void)loadCourseDescriptionWithDateStr:(NSString *)dateStr ID:(NSString *)ID paramKey:(NSString *)key method:(NSString *)method isSQL:(BOOL)isSQL finished:(void (^)(NSArray *))finished;
@end
