//
//  WDProgressView.m
//  在线编辑器
//
//  Created by 老船长 on 15/12/7.
//  Copyright © 2015年 伟东. All rights reserved.
//

#import "WDProgressView.h"
@interface WDProgressView ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;//颜色渐变
@property (nonatomic, strong) CAShapeLayer *arcLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *smallV;

@end
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define  PROGREESS_WIDTH 50 //圆直径
#define PROGRESS_LINE_WIDTH 3 //弧线的宽度
#define VIEW_SIZE 100//View大小
@implementation WDProgressView

- (instancetype)init {
    if (self = [super init]) {
        //遮罩
        UIButton *dummy = [UIButton buttonWithType:UIButtonTypeCustom];
        dummy.frame = [UIScreen mainScreen].bounds;
        dummy.backgroundColor = [UIColor blackColor];
        dummy.alpha = 0.5;
        [dummy addTarget:self action:@selector(cancleDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dummy];
        [self addSubview:self.smallV];
        [self.smallV addSubview:self.label];
        //轨迹圆
        self.arcLayer = [self creatShapeLayer];
        [self.layer addSublayer:self.arcLayer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(dummy.bounds.size.width * 0.5, dummy.bounds.size.height * 0.5) radius:(PROGREESS_WIDTH-PROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(0) endAngle: degreesToRadians(360) clockwise:YES];
        self.arcLayer.path = [path CGPath];
    }
    return self;
}
- (void)cancleDownload {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CANCLE_DOWNLOAD" object:nil];
}
- (void)drawArcWIthprogressValue:(CGFloat)value {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CURRENT_DEVICE_SIZE.width * 0.5, CURRENT_DEVICE_SIZE.height * 0.5) radius:(PROGREESS_WIDTH-PROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(-90) endAngle:value * degreesToRadians(360) + degreesToRadians(-90) clockwise:YES];
    self.shapeLayer.path =[path CGPath];
}
- (void)setValue:(CGFloat)value {
    _value = value;
    self.label.text = [NSString stringWithFormat:@"%d%%",(int)(value * 100)];
    [self drawArcWIthprogressValue:value];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.center = CGPointMake(VIEW_SIZE * 0.5, VIEW_SIZE * 0.5);
    self.shapeLayer.frame = self.smallV.bounds;
    self.arcLayer.frame = self.smallV.bounds;
}
- (void)test {
    //初始化渐变层
    self.gradientLayer = [CAGradientLayer layer];
//    self.gradientLayer.frame = self.progressV.bounds;
//    [self.progressV.layer addSublayer:self.gradientLayer];
    //设置渐变颜色方向
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
    
    //设定颜色组
    self.gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                  (__bridge id)[UIColor purpleColor].CGColor];
    
    //设定颜色分割点
    self.gradientLayer.locations = @[@(0.5f) ,@(1.0f)];
    
    //定时改变颜色
    self.gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                  (__bridge id)[UIColor colorWithRed:arc4random() % 255 / 255.0
                                                               green:arc4random() % 255 / 255.0
                                                                blue:arc4random() % 255 / 255.0
                                                               alpha:1.0].CGColor];
    //定时改变分割点
    self.gradientLayer.locations = @[@(arc4random() % 10 / 10.0f), @(1.0f)];
}
- (CAShapeLayer *)creatShapeLayer {
    //轨迹圆
    CAShapeLayer *arcLayer = [CAShapeLayer layer];
    arcLayer.fillColor = [UIColor clearColor].CGColor;
    arcLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    arcLayer.opacity = 0.8;
    arcLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    arcLayer.lineWidth = PROGRESS_LINE_WIDTH;
    return arcLayer;
}
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [self creatShapeLayer];
        _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;
}
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.frame =CGRectMake(0, 0, 30, 30);
        _label.text = @"0%";
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:10];
    }
    return _label;
}
- (UIView *)smallV {
    if (!_smallV) {
        _smallV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_SIZE, VIEW_SIZE)];
        _smallV.center = CGPointMake(CURRENT_DEVICE_SIZE.width * 0.5, CURRENT_DEVICE_SIZE.height * 0.5);
        _smallV.backgroundColor = [UIColor blackColor];
        _smallV.layer.cornerRadius = 8;
    }
    return _smallV;
}
@end
