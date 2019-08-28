//
//  HomeworkMainAnalysisCell.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeworkMainAnalysisCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;
@property (weak, nonatomic) IBOutlet UILabel *judgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
/// 得分label
@property (weak, nonatomic) IBOutlet UILabel *dfLabel;
/// 基线view
@property (weak, nonatomic) IBOutlet UIView *baseLineView;

+ (instancetype)selfCell;
- (void)setStnydWithNumber:(int)num;//试题难易度
@end
