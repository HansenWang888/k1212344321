//
//  HWInputScoresTableViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/10.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWInputScoresTableViewCell : UITableViewCell

///  分数
@property (nonatomic, strong) UITextField *gradeTextField;
///  评价
@property (nonatomic, strong) UITextField *evaluateTextField;
///  反馈按钮
@property (nonatomic, strong) UIButton *feedbackButton;

@end
