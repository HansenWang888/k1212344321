//
//  HWOnlineViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskModel;
@class StudentModel;

///  按人批改答案页面
@interface HWOnlineViewController : UIViewController

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;
///  学生答案
@property (nonatomic, strong) NSDictionary *studentAnswer;
///  学生
@property (nonatomic, strong) StudentModel *student;
///  是否反馈
@property (nonatomic, assign) BOOL isFeedback;
///  批改完成
@property (nonatomic, copy) void(^correctFinish)(StudentModel *model);

@end
