//
//  HomeworkTaskView.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkTaskView.h"
#import "Homework0101View.h"
#import "Homework0102View.h"
#import "Homework02View.h"
#import "Homework03View.h"
#import "Homework05View.h"
#import "Homework06View.h"

@implementation HomeworkTaskView

+ (instancetype)taskViewWithContentInfo:(HomeworkTaskModel *)info {
    
    NSDictionary *dict = @{@"0101":[Homework0101View class],
                           @"0102":[Homework0102View class],
                           @"02":[Homework02View class],
                           @"03":[Homework03View class],
                           @"05":[Homework05View class],
                           @"06":[Homework06View class]};
    HomeworkTaskView *view = [dict[info.stlx ? info.stlx : info.tmlx] new];
    view.backgroundColor = [UIColor whiteColor];
    view.cellHeightCache = @{}.mutableCopy;
    view.info = info;
    view.dataSource = view;
    view.delegate = view;
    view.tableFooterView = [UIView new];
    view.separatorStyle = UITableViewCellSelectionStyleNone;
    view.rowHeight = UITableViewAutomaticDimension;
    return view;
}
- (void)insertAnswerToTask {
}
- (void)setupSubCell {
}
- (CGFloat)getTaskViewHeight {
    CGFloat height = 0;
    for (NSString *value in self.cellHeightCache.allValues) {
        height += [value floatValue];
    }
    return height;
}
- (HomeworkTopicCell *)creatTopicCell {
    HomeworkTopicCell *topCell = [HomeworkTopicCell selfCell];
    NSDictionary *dict = @{@"0101" : NSLocalizedString(@"  单选题  ", nil),
                           @"0102" : NSLocalizedString(@"  多选题  ", nil),
                           @"02": NSLocalizedString(@"  填空题  ", nil),
                           @"03": NSLocalizedString(@"  判断题  ", nil),
                           @"05": NSLocalizedString(@"  简答题  ", nil),
                           @"06": NSLocalizedString(@"  综合题  ", nil)};
    topCell.typeLabel.text = dict[self.info.stlx];
//    topCell.typeLabel.layer.cornerRadius
    [topCell setValueForDataSource:[NSString stringWithFormat:@"%@",self.info.sttg] xh:self.info.pxbh fz:self.info.fz];
    self.cellHeightCache[@"0"] = @(CGRectGetMaxY(topCell.contentLabel.frame));
    return topCell;
}
- (void)setupAnalysisCell {
    NSMutableArray *arraM = @[].mutableCopy;
    UITableViewCell *cell = [UITableViewCell new];
    HomeworkAnalysisView *view = [HomeworkAnalysisView analysisViewWithModel:self.info isFeedback:self.isFeedback];
    self.cellHeightCache[[NSString stringWithFormat:@"%ld", self.subCells.count]] = @([view getViewHeight] + 40);
    [cell.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(20);
        make.right.bottom.offset(-20);
    }];
    [arraM addObject:cell];
    self.analysisCells = arraM.copy;
}
- (void)insertanalysisScore {
    
    UITableViewCell *cell = self.analysisCells[0];
    for (HomeworkAnalysisView *view in cell.contentView.subviews) {
        if (view.classForCoder == [HomeworkAnalysisView class]) {
            [view setupAnalysisCell];
            [view reloadData];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subCells.count + self.analysisCells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.row < self.subCells.count) {
        cell = self.subCells[indexPath.row];
    } else {
        cell = self.analysisCells[indexPath.row - self.subCells.count];
    }
    if (!self.isEdit) {
        cell.userInteractionEnabled = NO;
    } else {
        cell.userInteractionEnabled = YES;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] floatValue];
}

@end
