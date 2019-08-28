//
//  HWStudentTask.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/14.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWAccessoryModel;

///  学生作业模型
@interface HWStudentTask : NSObject

///  学生id
@property (nonatomic, copy) NSString *xsID;
///  评分
@property (nonatomic, copy) NSString *pf;
///  评语
@property (nonatomic, copy) NSString *py;
///  状态
@property (nonatomic, copy) NSString *zt;
///  学生姓名
@property (nonatomic, copy) NSString *xsxm;
///  附件列表
@property (nonatomic, strong) NSMutableArray<HWAccessoryModel *> *fjList;
///  教师附件列表
@property (nonatomic, strong) NSMutableArray<HWAccessoryModel *> *jsfjList;

@end
