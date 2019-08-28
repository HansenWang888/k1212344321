//
//  HWClassesTabView.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesTabView.h"

@interface HWClassesTabView ()
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBackgroudBtn;

@end
@implementation HWClassesTabView

+ (instancetype)classesTabView {
    return [[[NSBundle mainBundle] loadNibNamed:@"HWClassesTabView" owner:nil options:nil] lastObject];
}
- (IBAction)btnClick:(UIButton *)sender {
    if (sender == self.backBtn) {
        //返回
        if ([self.delegate respondsToSelector:@selector(classesTabBackButtonClick)]) {
            [self.delegate classesTabBackButtonClick];
        }
    } else if (sender == self.resetBtn) {
        //重置
        if ([self.delegate respondsToSelector:@selector(classesTabResetButtonClick)]) {
            [self.delegate classesTabResetButtonClick];
        }
    } else {
        //提交
        if ([self.delegate respondsToSelector:@selector(classesTabSubmitButtonClickWithStudentList:)]) {
            [self.delegate classesTabSubmitButtonClickWithStudentList:@[]];
        }
    }
}
- (void)hideSubmitButton {
    self.submitBtn.hidden = YES;
    self.submitBackgroudBtn.hidden = YES;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backBtn.titleLabel.numberOfLines = 2;
    self.resetBtn.titleLabel.numberOfLines = 2;
    [self.backBtn setTitle:[NSString stringWithFormat:@"  \U0000e655\n%@", NSLocalizedString(@"返回", nil)] forState:UIControlStateNormal];
    [self.resetBtn setTitle:[NSString stringWithFormat:@"  \U0000e62e\n%@", NSLocalizedString(@"重置", nil)] forState:UIControlStateNormal];
}
@end
