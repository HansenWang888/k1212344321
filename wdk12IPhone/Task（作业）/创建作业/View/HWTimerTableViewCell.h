//
//  HWTimerTableViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskTimerModel;

///  定时发布作业cell
@interface HWTimerTableViewCell : UITableViewCell

///  选择时间按钮
@property (nonatomic, strong) UIButton *selTimeButton;
///  删除按钮
@property (nonatomic, strong) UIButton *delButton;


- (void)setValueForDataSource:(HWTaskTimerModel *)data;

@end
