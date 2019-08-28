//
//  HomeworkTaskInfoVC.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;
@class HWTaskModel;
@class HomeworkTaskView;

@interface HomeworkTaskInfoVC : UIViewController

///  学生
@property (nonatomic, strong) StudentModel *student;
///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

+ (instancetype)taskInfoWithList:(NSArray *)stList with:(BOOL)isPreview isSubmit:(BOOL)isSubmit;

@end
