//
//  HWClassesStudentList.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWClassesStudentList : NSObject

@property (nonatomic, copy) NSString *kpbh;
@property (nonatomic, copy) NSString *xsID;
@property (nonatomic, copy) NSString *xsxm;
@property (assign, nonatomic) BOOL isScan;
@property (nonatomic, copy) NSString *selectedContent;//选项
@property (nonatomic, copy) NSString *xh;//序号
@property (nonatomic, copy) NSString *valueEncode;//编码值

+ (instancetype)classesStudentListWithDict:(NSDictionary *)dict;
@end
