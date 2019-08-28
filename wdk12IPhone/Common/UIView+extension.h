//
//  UIView+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (extension)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat w;
@property (assign, nonatomic) CGFloat h;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
///  快速创建view
///
///  @param color 背景颜色
///  @param alpha 透明度
///
///  @return view
+ (UIView *)viewWithBackground:(UIColor *)color alpha:(CGFloat)alpha;

///  添加底部阴影效果
- (void)getShadowOnBottom;

- (void)getShadowOnLeft;

///  添加虚线边框到四周
///
///  @param color 颜色
///  @param width 宽度
- (void)getBorderOnAllAroundWithColor:(UIColor *)color Width:(CGFloat)width;

@end
