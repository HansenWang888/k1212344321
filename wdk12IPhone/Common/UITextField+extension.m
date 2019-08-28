//
//  UITextField+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/21.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UITextField+extension.h"

@implementation UITextField (extension)

+ (UITextField *)textFieldBackgroundColor:(UIColor *)backgroundColor placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType {
    UITextField *textField = [UITextField new];
    if (backgroundColor) {
        textField.backgroundColor = backgroundColor;
    }
    if (placeholder) {
        textField.placeholder = placeholder;
    }
    if (keyboardType) {
        textField.keyboardType = keyboardType;
    }
    return textField;
}

@end
