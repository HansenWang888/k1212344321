
//
//  HWShowPictureTaskCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWShowPictureTaskCell.h"


@interface PhotoView : UIView

@end

@implementation PhotoView

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(12.5, 12.5) radius:12.5 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
    [path moveToPoint:CGPointMake(12.5, 0)];
    [path addLineToPoint:CGPointMake(70, 0)];
    [path addLineToPoint:CGPointMake(70, 25)];
    [path addLineToPoint:CGPointMake(12.5, 25)];
    [path closePath];
    UIColor *fillColor = [UIColor hex:0x797979 alpha:1.0];
    [fillColor set];
    [path fill];
    
}

@end

@interface HWShowPictureTaskCell ()

@property (nonatomic, strong) PhotoView *photoView;

@end

@implementation HWShowPictureTaskCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.imageView = [UIImageView new];
    [self addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = true;
    
    self.photoView = [PhotoView new];
    self.photoView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.photoView];

    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.stateLabel.textColor = [UIColor whiteColor];
    self.stateLabel.font = [UIFont systemFontOfSize:14];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.stateLabel];
}

- (void)initAutoLayout {
    [self.imageView zk_Fill:self.imageView insets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_top);
        make.right.equalTo(self.imageView.mas_right).offset(-10);
        make.height.equalTo(@25);
        make.width.equalTo(@60);
    }];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_top);
        make.right.equalTo(self.imageView.mas_right).offset(-10);
        make.height.equalTo(@25);
        make.width.equalTo(@70);
    }];
}

@end
