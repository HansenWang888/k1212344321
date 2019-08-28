//
//  WDQuestionCell.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  问题首页  无采纳数据 cell
 */
@class WDQuestionModel;
@interface WDQuestionCell : UITableViewCell

@property (nonatomic, strong) WDQuestionModel *questionModel;

@end
