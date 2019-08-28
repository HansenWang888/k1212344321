//
//  HomeworkAnalysisView.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/14.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkAnalysisView.h"
#import "HomeworkMainAnalysisCell.h"
#import "HomeworkOtherAnalysisCell.h"
#import "HomeworkTaskModel.h"

@interface HomeworkAnalysisView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSArray *subCells;
@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;
@property (nonatomic, strong) HomeworkTaskModel *info;

@end
@implementation HomeworkAnalysisView

+ (instancetype)analysisViewWithModel:(HomeworkTaskModel *)model isFeedback:(BOOL)isFeedback {
    HomeworkAnalysisView *view = [HomeworkAnalysisView new];
    view.isFeedback = isFeedback;
    view.dataSource = view;
    view.delegate = view;
    view.cellHeightCache = @{}.mutableCopy;
    view.info = model;
    [view setupAnalysisCell];
    view.separatorStyle = UITableViewCellSeparatorStyleNone;
    view.scrollEnabled = NO;
    return view;
}

- (void)setupAnalysisCell {
    NSMutableArray *arraM = @[].mutableCopy;
    HomeworkMainAnalysisCell *mainCell = [HomeworkMainAnalysisCell selfCell];
    NSArray *stlxs = @[@"0101", @"0102", @"03"];
    if (!self.info.isPreviewTask || [stlxs containsObject:self.info.stlx]) {
        self.cellHeightCache[[NSString stringWithFormat:@"%ld", arraM.count]] = @(65);
    }

    if (self.info.isPreviewTask || !self.info.mystda) {
        mainCell.dfLabel.alpha = 0;
    }
    
    if ((self.info.isPreviewTask && ![stlxs containsObject:self.info.stlx]) || !self.info.mystda) {
        self.cellHeightCache[[NSString stringWithFormat:@"%ld", arraM.count]] = @(15);
        mainCell.dfLabel.alpha = 0;
        mainCell.judgeLabel.alpha = 0;
        mainCell.fontLabel.alpha = 0;
        mainCell.baseLineView.alpha = 0;
    }
    
    
    if (self.info.mystda) {
        mainCell.scoreLabel.text = self.info.mystdf ? self.info.mystdf : @"";
        mainCell.judgeLabel.text = [self.info.mydasfzq isEqualToString:@"1"] ? NSLocalizedString(@"正确", nil) : NSLocalizedString(@"错误", nil);
        mainCell.fontLabel.text = [self.info.mydasfzq isEqualToString:@"1"] ? @"\U0000e64b" : @"\U0000e64c";
        if (!self.info.mydasfzq) { self.info.mydasfzq = @""; }
        if ([self.info.mystdf intValue] == 0 && [self.info.mydasfzq isEqualToString:@""]) {
            mainCell.judgeLabel.text = NSLocalizedString(@"待批改", nil);
            mainCell.fontLabel.text = @"\U0000e623";
        }
    }
    [arraM addObject:mainCell];

    HomeworkOtherAnalysisCell *analysisCell = [HomeworkOtherAnalysisCell new];
    analysisCell.analysisLabel.text = NSLocalizedString(@"解析:", nil);
    [analysisCell setValueForDataSource:self.info.stjx];
    self.cellHeightCache[[NSString stringWithFormat:@"%ld", arraM.count]] = @(CGRectGetMaxY(analysisCell.analysisContentLabel.frame) + 20);
    [arraM addObject:analysisCell];
    HomeworkOtherAnalysisCell *zsdCell = [HomeworkOtherAnalysisCell new];
    zsdCell.analysisLabel.text = NSLocalizedString(@"涉及知识点:", nil);
    [zsdCell setValueForDataSource:self.info.zsdmc ? self.info.zsdmc : @""];
    self.cellHeightCache[[NSString stringWithFormat:@"%ld", arraM.count]] = @(CGRectGetMaxY(zsdCell.analysisContentLabel.frame) + 20);
    [arraM addObject:zsdCell];
    HomeworkOtherAnalysisCell *stdaCell = [HomeworkOtherAnalysisCell new];
    stdaCell.analysisLabel.text = NSLocalizedString(@"试题答案:", nil);
    [stdaCell setValueForDataSource:self.info.stda ? self.info.stda : @""];
    self.cellHeightCache[[NSString stringWithFormat:@"%ld", arraM.count]] = @(CGRectGetMaxY(stdaCell.analysisContentLabel.frame) + 20);
    [arraM addObject:stdaCell];
//    }
    self.subCells = arraM.copy;
}
- (CGFloat)getViewHeight {
    CGFloat height = 0;
    for (NSString *value in self.cellHeightCache.allValues) {
        height += [value floatValue];
    }
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subCells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.subCells[indexPath.row];
    cell.userInteractionEnabled = false;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] floatValue];
}
@end
