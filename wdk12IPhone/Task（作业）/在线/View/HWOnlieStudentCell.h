//
//  HWOnlieStudentCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;
@class HWTaskModel;

@interface HWOnlieStudentCell : UITableViewCell

- (void)setValueForDataSource:(StudentModel *)data;

///  分
@property (nonatomic, strong) UILabel *numLabel;
///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

///  设置学生显示内容
///
///  @param data  学生模型
///  @param type  是否是小题类型
///  @param index 小题索引
///  @param stID  需要查找的试题id或小题id
- (void)setValueForDataSource:(StudentModel *)data type:(BOOL)type xtIndex:(NSInteger)index stID:(NSString *)stID;

@end
