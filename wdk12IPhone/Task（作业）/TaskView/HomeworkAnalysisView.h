//
//  HomeworkAnalysisView.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/14.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWAnswerTableView.h"

@class HomeworkTaskModel;
@interface HomeworkAnalysisView : HWAnswerTableView

///  是否反馈
@property (nonatomic, assign) BOOL isFeedback;

+ (instancetype)analysisViewWithModel:(HomeworkTaskModel *)model isFeedback:(BOOL)isFeedback;
- (CGFloat)getViewHeight;
- (void)setupAnalysisCell;
@end
