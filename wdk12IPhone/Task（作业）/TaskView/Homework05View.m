//
//  Homework05View.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "Homework05View.h"
#import "Homework05TextCell.h"

@implementation Homework05View

- (void)setupSubCell {
    
    NSMutableArray *arrayM = @[].mutableCopy;
    [arrayM addObject:[self creatTopicCell]];
    Homework05TextCell *cell = [Homework05TextCell new];
    cell.answer = self.info.mystda;
    self.cellHeightCache[[NSString stringWithFormat:@"%@",@(1)]] = @(CGRectGetMaxY(cell.contentLabel.frame) + 20);//@(300);
    [arrayM addObject:cell];
    self.subCells = arrayM.copy;
}
- (void)insertAnswerToTask {
    
    //插入答案和附件
    for (Homework05TextCell *cell in self.subCells) {
        if (cell.class == [Homework05TextCell class]) {
            if (self.info.mystda) {
                cell.answer = self.info.mystda;
            } else {
                cell.answer = @".";
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

@end
