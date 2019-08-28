//
//  UILabel+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UILabel+extension.h"

@implementation UILabel (extension)

+ (UILabel *)labelBackgroundColor:(UIColor *)color textColor:(UIColor *)textColor font:(UIFont *)font alpha:(CGFloat)alpha {
    UILabel *label = [UILabel new];
    if (color) {
        label.backgroundColor = color;
    }
    if (textColor) {
        label.textColor = textColor;
    }
    if (font) {
        label.font = font;
    }
    if (alpha) {
        label.alpha = alpha;
    }
    return label;
}

@end
