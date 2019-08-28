//
//  UIButton+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/5.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (extension)

///  快速创建按钮
///
///  @param font            字体
///  @param title           默认显示文字
///  @param titleColor      字体颜色
///  @param backgroundColor 按钮背景颜色
///
///  @return 按钮
+ (UIButton *)buttonWithFont:(UIFont *)font title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

///  快速创建按钮
///
///  @param imageName 图片名称
///  @param title     文字
///  @param font      字体
///  @param color     字体颜色
///
///  @return 按钮
+ (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color;

@end
