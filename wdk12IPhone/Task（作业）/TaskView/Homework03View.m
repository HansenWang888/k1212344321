//
//  Homework03View.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "Homework03View.h"
//#import "HomeworkChoiceCell.h"
#import "JudgementTableViewCell.h"

@implementation Homework03View

- (void)setupSubCell {
    NSMutableArray *arrayM = @[].mutableCopy;
    [arrayM addObject:[self creatTopicCell]];
    //生成选项Cell
    for (int i = 0; i<2; i++) {        
        JudgementTableViewCell *cell = [JudgementTableViewCell new];
        
        [cell.serialNumButton setTitle:i == 0 ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil) forState:(UIControlStateNormal)];
        self.cellHeightCache[[NSString stringWithFormat:@"%d", i + 1]] = @(64);
        [arrayM addObject:cell];
    }
    self.subCells = arrayM.copy;
}
- (void)insertAnswerToTask {
    //插入答案
    for (JudgementTableViewCell *cell in self.subCells) {
        if (cell.class == [JudgementTableViewCell class]) {
            if (self.info.mystda.length > 0) {
                if ([self.info.mystda isEqualToString:@"1"] && [cell.serialNumButton.titleLabel.text isEqualToString:NSLocalizedString(@"对", nil)]) {
                    cell.isSelect = true;
                }
                if ([self.info.mystda isEqualToString:@"0"] && [cell.serialNumButton.titleLabel.text isEqualToString:NSLocalizedString(@"错", nil)]) {
                    cell.isSelect = true;
                }
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
