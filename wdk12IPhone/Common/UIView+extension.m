//
//  UIView+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UIView+extension.h"
#import "UIColor+Hex.h"

@implementation UIView (extension)


- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setW:(CGFloat)w {
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (CGFloat)w {
    return self.frame.size.width;
}

- (void)setH:(CGFloat)h {
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

- (CGFloat)h {
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGFloat)centerX {
    
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    
    CGPoint newCenter = self.center;
    newCenter.x       = centerX;
    self.center       = newCenter;
}

- (CGFloat)centerY {
    
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    
    CGPoint newCenter = self.center;
    newCenter.y       = centerY;
    self.center       = newCenter;
}

- (void)getShadowOnBottom {
    self.layer.shadowColor = [UIColor hex:0x000000 alpha:0.2].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 0;
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
}

- (void)getShadowOnLeft {
    self.layer.shadowColor = [UIColor hex:0x000000 alpha:0.2].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 1;
    //    self.layer.borderWidth  = 0.5;
    self.layer.shadowOffset = CGSizeMake(-2, 0);
}

+ (UIView *)viewWithBackground:(UIColor *)color alpha:(CGFloat)alpha {
    UIView *v = [UIView new];
    v.backgroundColor = color;
    v.alpha = alpha;
    return v;
}

- (void)getBorderOnAllAroundWithColor:(UIColor *)color Width:(CGFloat)width {
    
    self.layer.borderColor = color ? color.CGColor : [UIColor hex:0xCBCCCD alpha:1.0].CGColor;
    self.layer.borderWidth = width ? width : 0.5;
}

@end
