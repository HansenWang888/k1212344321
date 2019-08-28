//
//  JSONUtil.h
//  wdk12IPhone
//
//  Created by macapp on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <uikit/uikit.h>

@interface UIColor(HEX)

+(UIColor*)ColorWithHexRGBA:(NSString*)hex_rgba_str;

/**
 *  快速创建颜色
 *
 *  @param hex   16进制颜色 例：0xFFFFFF 白色
 *  @param alpha 透明度
 *
 *  @return 颜色
 */
+ (UIColor *)hex:(uint)hex alpha:(CGFloat)alpha;

/**
 *  随机色
 *
 *  @return 颜色
 */
+ (UIColor *)randomColor;

@end
