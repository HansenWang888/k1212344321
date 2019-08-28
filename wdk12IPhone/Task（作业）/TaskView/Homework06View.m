//
//  Homework06View.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "Homework06View.h"

@implementation Homework06View

- (void)setupSubCell {
    NSMutableArray *arrayM = @[].mutableCopy;
    [arrayM addObject:[self creatTopicCell]];
    int i = 1;
    for (HomeworkTaskModel *newInfo in self.info.stxtList) {
        HomeworkTaskView *taskView = [HomeworkTaskView taskViewWithContentInfo:newInfo];
        taskView.isXT = YES;
        [taskView setupSubCell];
        if (newInfo.isSubmit) {            
            [taskView setupAnalysisCell];
            [taskView insertAnswerToTask];
        }
        [arrayM addObject:[self creatCellWithInfo:taskView]];
        taskView.scrollEnabled = false;
        self.cellHeightCache[[NSString stringWithFormat:@"%d", i]] = @([taskView getTaskViewHeight]);
        i++;
    }
    self.subCells = arrayM.copy;
}
- (Homework06TaskCell *)creatCellWithInfo:(HomeworkTaskView *)view {
    Homework06TaskCell *cell = [Homework06TaskCell new];
    [cell.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.right.bottom.top.offset(0);
    }];
    cell.shadeView = [UIView new];
    [cell addSubview:cell.shadeView];
    [cell.shadeView zk_Fill:cell insets:UIEdgeInsetsZero];
    cell.taskView = view;
    return cell;
}
- (void)insertAnswerToTask {
    // 插入答案
    for (Homework06TaskCell *cell in self.subCells) {
        if (cell.class == [Homework06TaskCell class]) {
            [cell.taskView insertAnswerToTask];
        }
    }
    
    [self setupAnalysisCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subCells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Homework06TaskCell *cell = self.subCells[indexPath.row];
    if ([cell isKindOfClass:[Homework06TaskCell class]]) {
        for (UITableViewCell *c in cell.taskView.visibleCells) {
            c.userInteractionEnabled = true;
        }
    }
    cell.userInteractionEnabled = true;
    return cell;
    
}

- (void)insertanalysisScore {
    
    for (Homework06TaskCell *cell in self.subCells) {
        if (cell.class == [Homework06TaskCell class]) {
            UITableViewCell *analysisCell = cell.taskView.analysisCells[0];
            for (HomeworkAnalysisView *view in analysisCell.contentView.subviews) {
                if (view.classForCoder == [HomeworkAnalysisView class]) {
                    [view setupAnalysisCell];
                    [view reloadData];
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return ;
    }
    if (self.didSel) {
        self.didSel(indexPath);
    }
//    self.leftTextLabel.text = [NSString stringWithFormat:@"%tu", indexPath.row];
//    self.leftTextLabel.tag = indexPath.row;
    Homework06TaskCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[Homework06TaskCell class]]) {
        self.tempCell.shadeView.backgroundColor = [UIColor clearColor];
        cell.shadeView.backgroundColor = [UIColor hex:0x000000 alpha:0.3];
        self.tempCell = cell;
    }
    
}

@end
@implementation Homework06TaskCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

@end
