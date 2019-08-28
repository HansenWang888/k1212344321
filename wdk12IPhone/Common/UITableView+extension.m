//
//  UITableView+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UITableView+extension.h"

@implementation UITableView (extension)

+ (UITableView *)tableViewWithSuperView:(UIView *)superView dataSource:(__kindof NSObject *)object backgroundColor:(UIColor *)backgroundColor separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle registerCell:(Class)cellClass cellIdentifier:(NSString *)cellIdentifier {
    UITableView *tableView = [[UITableView alloc] init];
    if (superView) {
        [superView addSubview:tableView];
    }
    if (object) {
        tableView.dataSource = object;
        tableView.delegate = object;
    }
    if (backgroundColor) {
        tableView.backgroundColor = backgroundColor;
    }
    tableView.separatorStyle = separatorStyle;
    if (cellClass != nil && cellIdentifier != nil) {
        [tableView registerClass:cellClass forCellReuseIdentifier:cellIdentifier];
    }
    return tableView;
}

@end
