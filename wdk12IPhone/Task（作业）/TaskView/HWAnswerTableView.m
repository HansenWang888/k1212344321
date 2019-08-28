//
//  HWAnswerTableView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/9/3.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWAnswerTableView.h"

@implementation HWAnswerTableView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat y = CGRectGetMaxY(rect);
    CGFloat w = CGRectGetMaxX(rect);
    [path moveToPoint:CGPointMake(0, 10)];
    [path addLineToPoint:CGPointMake(0, y)];
    [path addLineToPoint:CGPointMake(w, y)];
    [path addLineToPoint:CGPointMake(w, 10)];
    [path addLineToPoint:CGPointMake(30, 10)];
    [path addLineToPoint:CGPointMake(25, 0)];
    [path addLineToPoint:CGPointMake(20, 10)];
    [path addLineToPoint:CGPointMake(0, 10)];
    CGContextAddPath(ctx, path.CGPath);
    [[UIColor hex:0x000000 alpha:0.7] setFill];
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextDrawPath(ctx, kCGPathFill);
    [super drawRect:rect];
}


@end
