//
//  WDCourseList.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCourseList : NSObject
@property (nonatomic, copy) NSString *courseTime;//课程时间
@property (nonatomic, copy) NSString *courseContent;//课程内容
@property (nonatomic, copy) NSString *grade;//年级
@property (nonatomic, copy) NSString *classesName;//班级名称
@property (nonatomic, copy) NSString *subject;//科目
//获取指定班级课表时才有的数据
@property (nonatomic, copy) NSString *teacherName;//老师名称
@property (nonatomic, copy) NSString *teacherID;//老师ID



+ (instancetype)listWithDict:(NSDictionary *)dict;

@end
