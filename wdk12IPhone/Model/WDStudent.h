//
//  WDStudent.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/11/10.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDStudent : NSObject
@property (nonatomic, copy) NSString *account;//帐号
@property (nonatomic, copy) NSString *headPhoto;//头像
@property (nonatomic, copy) NSString *infoID;//该信息ID
@property (nonatomic, copy) NSString *studentID;//学生ID
@property (nonatomic, copy) NSString *studentName;//学生姓名
@property (nonatomic, copy) NSString *PCRelation;//亲子关系
@property (nonatomic, copy) NSArray *classesList;//所在班级，里面放的是字典bjID

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)studentWithDict:(NSDictionary *)dict;
@end
