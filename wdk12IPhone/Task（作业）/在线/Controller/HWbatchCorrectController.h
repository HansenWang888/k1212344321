//
//  HWbatchCorrectController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWTaskModel.h"

@class StudentModel;

///  按题批改控制器
@interface HWbatchCorrectController : UIViewController

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;
///  学生
@property (nonatomic, copy) NSArray<StudentModel *> *data;
///  学生答案
@property (nonatomic, copy) NSArray *answerData;

@end
