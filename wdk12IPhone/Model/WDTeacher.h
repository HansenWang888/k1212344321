//
//  WDTeacher.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDUser.h"

@interface WDTeacher : WDUser

@property (nonatomic, copy) NSArray *masterList;//班主任班级，只包括班级信息
@property (nonatomic, copy) NSArray *teacherList;//任课老师，包括班级信息和科目
@property (nonatomic, copy) NSString *teacherID;//老师ID
@property (nonatomic, copy) NSString *schoolID;//学校ID
@property (nonatomic, strong) NSString *teacherLevel;//老师等级

- (instancetype)initWithDict:(NSDictionary *)dict ;

@end