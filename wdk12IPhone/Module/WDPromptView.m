//
//  WDPromptView.m
//  wdk12studyHD-T
//
//  Created by 老船长 on 16/1/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "WDPromptView.h"

@interface WDPromptView ()
@property (weak, nonatomic) IBOutlet UILabel *labelV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelXConstraint;

@end

@implementation WDPromptView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)promptView {
    WDPromptView *promtV = [[NSBundle mainBundle] loadNibNamed:@"WDPromptView" owner:nil options:nil].lastObject;
    return promtV;
}
- (void)setPromptMessage:(NSString *)promptMessage {
    _promptMessage = promptMessage;
    self.labelV.text = promptMessage;
}
- (void)setPromtVWithHidden:(BOOL)isHidden isAnimation:(BOOL)isAnimation activityHidden:(BOOL)activityIsH promtStr:(NSString *)promtStr {
    self.hidden = isHidden;
    if (isAnimation) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
    self.labelV.text = promtStr;
    if (activityIsH) {
        self.labelXConstraint.constant = 0;
    }
    self.activityView.hidden = activityIsH;
}

@end
