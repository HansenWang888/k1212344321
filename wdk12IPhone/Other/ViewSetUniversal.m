//
//  WDSettelPublishView.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ViewSetUniversal.h"

@implementation ViewSetUniversal

+ (void)setButton:(UIButton *)btn title:(NSString *)title fontSize:(CGFloat)fontSize textColor:(UIColor *)color fontName:(NSString *)fontName action:(SEL)action target:(id)target {
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
}
+ (void)setButton:(UIButton *)btn fontAttr:(NSString *)fontAttr fontSize:(CGFloat)fontSize textColor:(UIColor *)color contentAttr:(NSString *)contentAttr action:(SEL)action target:(id)target {
    NSAttributedString *attrStr = [self attributedStringWithFontStr:fontAttr sizeFont:fontSize contentStr:contentAttr titltleColor:color];
    [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
}
+ (NSAttributedString *)attributedStringWithFontStr:(NSString *)fontStr sizeFont:(CGFloat)sizeFont contentStr:(NSString *)contentStr titltleColor:(UIColor *)color {
    NSAttributedString *fontAttr = [[NSAttributedString alloc] initWithString:fontStr attributes:@{NSFontAttributeName : [UIFont fontWithName:@"iconfont" size:sizeFont],NSForegroundColorAttributeName : color}];
    NSAttributedString *contentAttr = [[NSAttributedString alloc] initWithString:contentStr attributes:@{NSForegroundColorAttributeName : color,NSFontAttributeName : [UIFont fontWithName:@"iconfont" size:sizeFont]}];
    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] init];
    [attrM appendAttributedString:fontAttr];
    [attrM appendAttributedString:contentAttr];
    return attrM.copy;
}
+ (void)setView:(UIView *)view cornerRadius:(CGFloat)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}
+ (void)setView:(UIView *)view borderWitdth:(CGFloat)width borderColor:(UIColor *)color {
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
}
+ (void)setShadowView:(UIView *)view shadowColor:(UIColor *)color shadowOpacity:(float)opacity shadoeOffset:(CGSize)offset shadowRadius:(float)radius shadowPath:(CGRect)rect {
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = radius;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
}
@end
