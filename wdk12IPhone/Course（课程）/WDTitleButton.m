//
//  WDTitleButton.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/23.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDTitleButton.h"

@implementation WDTitleButton

- (void)layoutSubviews {
    [super layoutSubviews];
    //重定义按钮中图片和文字的位置
    CGRect titleF = self.titleLabel.frame;
    CGRect imageF = self.imageView.frame;
    imageF.origin.x = self.titleLabel.frame.size.width + 5;
    self.imageView.frame = imageF;
    titleF.origin.x = 0;
    self.titleLabel.frame = titleF;
}
@end
