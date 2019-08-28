//
//  HomeworkTopicCell.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeworkTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
/// 总分数
@property (weak, nonatomic) IBOutlet UILabel *countScore;

- (void)setValueForDataSource:(NSString *)data xh:(NSString *)btxh fz:(NSString *)fz;

+ (instancetype)selfCell;
@end
