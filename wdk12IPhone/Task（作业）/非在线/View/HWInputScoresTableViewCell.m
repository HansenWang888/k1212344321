//
//  HWInputScoresTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/10.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWInputScoresTableViewCell.h"

@implementation HWInputScoresTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.gradeTextField = [UITextField textFieldBackgroundColor:nil placeholder:NSLocalizedString(@"评分", nil) keyboardType:UIKeyboardTypeDecimalPad];
    self.evaluateTextField = [UITextField textFieldBackgroundColor:nil placeholder:NSLocalizedString(@"请输入对该同学的评语", nil) keyboardType:UIKeyboardTypeDefault];
    self.feedbackButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"反馈", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x349B8C alpha:1.0]];
    
    self.gradeTextField.borderStyle = UITextBorderStyleNone;
    self.evaluateTextField.borderStyle = UITextBorderStyleNone;
    self.gradeTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.evaluateTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.gradeTextField.layer.borderWidth = 0.5;
    self.evaluateTextField.layer.borderWidth = 0.5;
    self.gradeTextField.layer.cornerRadius = 3;
    self.evaluateTextField.layer.cornerRadius = 3;
    
    
    [self.contentView addSubview:self.gradeTextField];
    [self.contentView addSubview:self.feedbackButton];
    [self.contentView addSubview:self.evaluateTextField];
    
    self.gradeTextField.tag = 1;
    self.evaluateTextField.tag = 2;
    self.feedbackButton.layer.cornerRadius = 3;
}

- (void)initAutoLayout {
    [self.gradeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.offset(10);
        make.width.offset(50);
        make.height.offset(37);
    }];
    [self.feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10);
        make.top.offset(10);
        make.width.offset(70);
        make.height.offset(37);
    }];
    [self.evaluateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.gradeTextField.mas_right).offset(10);
        make.right.mas_equalTo(self.feedbackButton.mas_left).offset(-10);
        make.top.offset(10);
        make.height.offset(37);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
