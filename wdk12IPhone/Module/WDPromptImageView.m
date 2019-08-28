//
//  WDPromptImageView.m
//  wdk12IPhone
//
//  Created by wangdi on 16/6/1.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDPromptImageView.h"

@interface WDPromptImageView ()

@end

@implementation WDPromptImageView


+ (instancetype)promptImageView {
    WDPromptImageView *promtV = [[NSBundle mainBundle] loadNibNamed:@"WDPromptImageView" owner:nil options:nil].lastObject;
    return promtV;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
