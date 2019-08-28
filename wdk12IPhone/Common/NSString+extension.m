//
//  NSString+extension.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "NSString+extension.h"

@implementation NSString (extension)

- (CGSize)sizeOfStringWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *affe = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:affe context:nil].size;
}

@end
