//
//  UIScreen+extension.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/6/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "UIScreen+extension.h"

@implementation UIScreen (extension)

+ (CGFloat)wd_screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)wd_screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)wd_scale {
    return [UIScreen mainScreen].scale;
}

@end
