//
//  WDSettelPublishView.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
//设置对象的属性
@interface ViewSetUniversal : NSObject

+ (void)setButton:(UIButton *)btn title:(NSString *)title fontSize:(CGFloat)fontSize textColor:(UIColor *)color fontName:(NSString *)fontName action:(SEL)action target:(id)target;
+ (void)setButton:(UIButton *)btn fontAttr:(NSString *)fontAttr fontSize:(CGFloat)fontSize textColor:(UIColor *)color contentAttr:(NSString *)contentAttr action:(SEL)action target:(id)target;

+ (void)setView:(UIView *)view cornerRadius:(CGFloat)radius;
+ (void)setView:(UIView *)view borderWitdth:(CGFloat)width borderColor:(UIColor *)color;
+ (void)setShadowView:(UIView *)view shadowColor:(UIColor *)color shadowOpacity:(float)opacity shadoeOffset:(CGSize)offset shadowRadius:(float)radius shadowPath:(CGRect)rect;
@end
