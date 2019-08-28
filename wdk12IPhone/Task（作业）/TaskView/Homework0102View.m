//
//  Homework0102View.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "Homework0102View.h"
#import "HomeworkChoiceCell.h"

@implementation Homework0102View

- (void)setupSubCell {
    NSMutableArray *arrayM = @[].mutableCopy;
    [arrayM addObject:[self creatTopicCell]];
    int i = 1;
    //生成选项Cell
    for (NSDictionary *dict in self.info.stxux) {
        HomeworkChoiceCell *cell = [HomeworkChoiceCell new];
        [cell setValueForDataSource:dict];
        CGFloat height = cell.contentLabel.frame.size.height;
        if (height < 44) {
            height = 44;
        }
        self.cellHeightCache[[NSString stringWithFormat:@"%d",i]] = @(height);
        [arrayM addObject:cell];
        i ++;
    }
    self.subCells = arrayM.copy;
}
- (void)insertAnswerToTask {
    //插入答案
    for (HomeworkChoiceCell *cell in self.subCells) {
        if (cell.class == [HomeworkChoiceCell class]) {
            NSArray *da = [self.info.mystda componentsSeparatedByString:@","];
            for (NSString *str in da) {
                if ([cell.serialNumButton.titleLabel.text isEqualToString:str]) {
                    cell.isSelect = YES;
                }
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
@end
