//
//  HWAnswerDetailController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/18.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;
@class HWTaskModel;

///  答案详情控制器
@interface HWAnswerDetailController : UIViewController

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

@property (nonatomic, copy) void(^gradeContent)(NSDictionary *dict);

///  设置数据源方法
///
///  @param sjId    试卷id
///  @param type    是否是小题
///  @param student 学生模型
///  @param index   小题索引
//- (void)setValueForDataSourceWith:(NSString *)sjId type:(BOOL)type student:(StudentModel *)student;

- (void)setValueForDataSourceWith:(NSString *)sjId type:(BOOL)type student:(StudentModel *)student stId:(NSString *)stId xtId:(NSString *)xtId;

@end
