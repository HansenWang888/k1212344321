//
//  HWStudentListController.h
//  demo
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWDragView;
@class HWTaskModel;

@interface HWStudentListView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HWDragView *dragView;

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;

@property (nonatomic, copy) void(^didSelect)(NSIndexPath *index);

///  设置学生显示内容
///
///  @param data  数据源
///  @param type  是否是小题
///  @param index 小题索引
///  @param stID  试题id
- (void)setValueForDataSource:(NSArray *)data type:(BOOL)type xtIndex:(NSInteger)index stID:(NSString *)stID;

@end
