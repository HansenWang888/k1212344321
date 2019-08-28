//
//  UITableView+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (extension)

///  快速创建tableView及设置参数
///
///  @param superView       父view
///  @param object          遵守数据源和代理的协议对象，一般是控制器或view
///  @param backgroundColor 背景颜色
///  @param separatorStyle  基线样式
///  @param cellClass       注册cell类型
///  @param cellIdentifier  注册cell标识符，一般是类名
///
///  @return tableView
+ (UITableView *)tableViewWithSuperView:(UIView *)superView dataSource:(__kindof NSObject *)object backgroundColor:(UIColor *)backgroundColor separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle registerCell:(Class)cellClass cellIdentifier:(NSString *)cellIdentifier;

@end
