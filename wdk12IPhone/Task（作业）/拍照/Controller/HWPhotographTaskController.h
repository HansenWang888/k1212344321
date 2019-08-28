//
//  HWPhotographTaskController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPhotographModel;
@class HWTaskModel;
@class StudentModel;

///  拍照作业控制器
@interface HWPhotographTaskController : UIViewController

@property (nonatomic, strong) NSMutableArray *stData;
///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

@property (nonatomic, strong) HWPhotographModel *xsData;


///  学生
@property (nonatomic, strong) StudentModel *student;
///  批改完成
@property (nonatomic, copy) void(^correctFinish)(StudentModel *model);

@end
