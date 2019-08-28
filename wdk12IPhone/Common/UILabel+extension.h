//
//  UILabel+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (extension)

///  快速创建label及设置参数, 所有参数均可传nil
///
///  @param color     背景颜色
///  @param textColor 文字颜色
///  @param font      字体
///  @param alpha     透明度
///
///  @return label
+ (UILabel *)labelBackgroundColor:(UIColor *)color textColor:(UIColor *)textColor font:(UIFont *)font alpha:(CGFloat)alpha;

@end
