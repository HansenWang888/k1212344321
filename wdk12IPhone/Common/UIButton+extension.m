//
//  UIButton+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/5.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UIButton+extension.h"

@implementation UIButton (extension)

+ (UIButton *)buttonWithFont:(UIFont *)font title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (font != nil) {
        btn.titleLabel.font = font;
    }
    if (title != nil) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (titleColor != nil) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }
    if (backgroundColor != nil) {
        btn.backgroundColor = backgroundColor;
    }
    [btn sizeToFit];
    return btn;
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (![imageName isEqualToString:@""]) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (![title isEqualToString:@""]) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (font) {
        btn.titleLabel.font = font;
    }
    if (color != nil) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
    return btn;
}

@end
