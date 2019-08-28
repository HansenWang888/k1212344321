//
//  WDCourseList.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/29.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDCourseList.h"

@implementation WDCourseList

+ (instancetype)listWithDict:(NSDictionary *)dict {

    WDCourseList *course = [[self alloc] init];

    course.courseTime = dict[@"kssj"];
    course.courseContent = dict[@"zxnr"];
    course.grade = dict[@"nj"];
    course.classesName = dict[@"bjmc"];
    course.subject = dict[@"km"];
    
    course.teacherID = dict[@"jsID"];
    course.teacherName = dict[@"jsmc"];
    return course;
}

@end
