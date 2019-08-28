//
//  HWTaskListTableViewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskModel;

///  作业列表cell
@interface HWTaskListTableViewCell : UITableViewCell

///  底部view
@property (nonatomic, strong) UIView *bottomView;

- (void)setValueForDataSource:(HWTaskModel *)data;

@end
