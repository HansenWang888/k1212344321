//
//  WDAnsweredQuestionCell.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  问题首页  有采纳数据 cell
 */

@class WDQuestionModel;

@interface WDAnsweredQuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *answerTextView;

@property (nonatomic, strong) WDQuestionModel *answerQuestionModel;

@end
