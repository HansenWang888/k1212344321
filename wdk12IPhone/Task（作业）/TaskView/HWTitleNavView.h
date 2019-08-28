//
//  HWTitleNavView.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  题目导航view
@interface HWTitleNavView : UIView

///  题目导航按钮
@property (nonatomic, strong) UIButton *topicNavButton;
///  当前标题
@property (nonatomic, strong) UILabel *currentTitleLabel;
///  总数标题
@property (nonatomic, strong) UILabel *countTitleLabel;

@end
