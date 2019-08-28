//
//  JSONUtil.m
//  wdk12IPhone
//
//  Created by macapp on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "UIColor+Hex.h"


@implementation UIColor(HEX)

+(UIColor*)ColorWithHexRGBA:(NSString*)hex_rgba_str{
    
    if(hex_rgba_str.length != 9) {
        NSLog(@"UIColor error: ColorWithHexRGBA  hex_rgba_str.length != 9 ");
        return nil;
    }
    hex_rgba_str = [NSString stringWithFormat:@"0x%@",[hex_rgba_str substringFromIndex:1]];
    NSScanner * scanner = [[NSScanner alloc] initWithString:hex_rgba_str] ;
    unsigned int o;
    [scanner scanHexInt:&o];
    
    float r = ((o&0XFF000000)>>24) /255.0;
    float g = ((o&0X00FF0000)>>16) /255.0;
    float b = ((o&0X0000FF00)>>8) /255.0;
    float a = (o&0X000000FF) /255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)hex:(uint)hex alpha:(CGFloat)alpha {
    
    return [[UIColor alloc] initWithRed:((hex & 0xFF0000) >> 16) / 255.0
                                  green:((hex & 0x00FF00) >> 8) / 255.0
                                   blue:(hex & 0x000FF) / 255.0
                                  alpha:alpha];
}

+ (UIColor *)randomColor {
    
    CGFloat r = [UIColor randomValue];
    CGFloat g = [UIColor randomValue];
    CGFloat b = [UIColor randomValue];
    return [[UIColor alloc] initWithRed:r green:g blue:b alpha:0.5];
}

+ (CGFloat)randomValue {
    return (arc4random_uniform(256.0)) / 255.0;
}


@end