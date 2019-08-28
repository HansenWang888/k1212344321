//
//  NSString+extension.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (extension)

///  计算文字大小
///
///  @param font    字体
///  @param maxSize 文字最大的大小，建议宽度有值，高度为CGFLOAT_MAX
///
///  @return 字体大小
- (CGSize)sizeOfStringWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
