//
//  UITextField+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/21.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (extension)

///  快速创建textField
///
///  @param backgroundColor 背景颜色
///  @param placeholder     默认显示字
///  @param keyboardType    键盘样式
///
///  @return textfield
+ (UITextField *)textFieldBackgroundColor:(UIColor *)backgroundColor placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType;

@end
