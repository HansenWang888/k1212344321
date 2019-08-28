//
//  CenterTextFieldCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "CenterTextFieldCell.h"

@interface CenterTextFieldCell ()<UITextFieldDelegate>

@end

@implementation CenterTextFieldCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.textField = [UITextField textFieldBackgroundColor:nil placeholder:nil keyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [self addSubview:self.textField];
    self.textField.delegate = self;
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)initAutoLayout {
    [self.textField zk_Fill:self insets:UIEdgeInsetsZero];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end
