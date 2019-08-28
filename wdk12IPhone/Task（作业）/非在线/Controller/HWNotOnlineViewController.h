//
//  NotOnlineViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;
@class HWTaskModel;
@class HWStudentTask;

///  非在线作业控制器
@interface HWNotOnlineViewController : UIViewController

///  学生模型
@property (nonatomic, strong) StudentModel *studentModel;
///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

@property (nonatomic, strong) HWStudentTask *studentTask;
///  批改完成
@property (nonatomic, copy) void(^correctFinish)(StudentModel *model);
///  是否提交
@property (nonatomic, assign) BOOL isSubmit;

@end
