//
//  UIImage+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UIImage+extension.h"

@implementation UIImage (extension)

- (UIImage *)scaleImageWithWidth:(CGFloat)width {
    if (width > self.size.width) {
        return self;
    }
    CGFloat height = self.size.height * width / self.size.width;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
