//
//  HWTitleLabel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/9/3.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTitleLabel.h"

@implementation HWTitleLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(5, 0)];
    [path addLineToPoint:CGPointMake(5, 30)];
    [path addLineToPoint:CGPointMake(20, 30)];
    [path addLineToPoint:CGPointMake(25, 35)];
    [path addLineToPoint:CGPointMake(30, 30)];
    [path addLineToPoint:CGPointMake(115, 30)];
    [path addLineToPoint:CGPointMake(115, 0)];
    [path addLineToPoint:CGPointMake(5, 0)];
    CGContextAddPath(ctx, path.CGPath);
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextDrawPath(ctx, kCGPathFill);
    [super drawRect:rect];
}


@end
