//
//  WDAnswerDetailCell.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  问题详情页面  回答和回复 cell（回答有回复和采纳按钮）
 */

@class WDAnswerDetailModel;
@interface WDAnswerDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, copy) void (^cainaBlock)(WDAnswerDetailModel *model);
@property (nonatomic, copy) void (^huifuBlock)(WDAnswerDetailModel *model);
@property (nonatomic,assign) BOOL isCaiNa;
- (void)setCellWithModel:(WDAnswerDetailModel *)model isFirst:(BOOL)isFirst isMe:(BOOL)isMe;

@end
