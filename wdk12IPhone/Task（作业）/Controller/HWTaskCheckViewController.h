//
//  HWTaskCheckViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWStudentTask;
@class HWTaskModel;

///  作业查看控制器
@interface HWTaskCheckViewController : UIViewController

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

///  重置提交状态数量
- (void)resetSubmitStatusCount;

@end
