//
//  HomeworkTaskView.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeworkTaskModel.h"
#import "HomeworkTopicCell.h"
#import "HWTextLeftLabel.h"
#import "HomeworkAnalysisView.h"
@interface HomeworkTaskView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) HomeworkTaskModel *info;
@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;//缓存行高
@property (nonatomic, copy) NSArray *subCells;
@property (nonatomic, copy) NSArray *analysisCells;//解析所包含的cell
@property (assign, nonatomic) BOOL isXT;//是否为小题
@property (assign, nonatomic) BOOL isAnalysis;//是否显示解析
@property (assign, nonatomic) BOOL isEdit;//是否能编辑
@property (nonatomic, weak) HWTextLeftLabel *leftTextLabel;
///  是否反馈
@property (nonatomic, assign) BOOL isFeedback;

+ (instancetype)taskViewWithContentInfo:(HomeworkTaskModel *)info;
- (void)insertAnswerToTask;
- (void)setupSubCell;
- (void)setupAnalysisCell;
- (CGFloat)getTaskViewHeight;
- (HomeworkTopicCell *)creatTopicCell;
- (void)insertanalysisScore;

@end
