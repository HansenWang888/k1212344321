//
//  OnlineTaskOtherSubjectView.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/14.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "OnlineTaskOtherSubjectView.h"
#import "ShowSubjectTableViewCell.h"
#import "HWQuestionPaper.h"
#import <Masonry.h>

@interface OnlineTaskOtherSubjectView ()

@property (nonatomic, strong) UITableView *tableview;

@end

@implementation OnlineTaskOtherSubjectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

///  初始化退出按钮，点任意位置退出
- (void)initView {

    self.tableview = [UITableView tableViewWithSuperView:self dataSource:self backgroundColor:[UIColor hex:0x565656 alpha:1.0] separatorStyle:(UITableViewCellSeparatorStyleNone) registerCell:[ShowSubjectTableViewCell class] cellIdentifier:@"ShowSubjectTableViewCell"];
    self.tableview.rowHeight = 40;
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

#pragma mark - tableViewDelegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowSubjectTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"ShowSubjectTableViewCell" forIndexPath:indexPath];
    HWQuestionPaper *data = self.dataSource[indexPath.row];
    [cell setValueForDataSource:data.sjMC];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock(self.dataSource[indexPath.row]);
    }
}

- (void)setDataSource:(NSArray<HWQuestionPaper *> *)dataSource {
    _dataSource = dataSource;
    [self.tableview reloadData];
}

@end
