//
//  HWDragView.m
//  demo
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWDragView.h"
#import "UIView+extension.h"

@interface HWDragView ()

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *baseLineView;

@end

@implementation HWDragView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.bottomView = [UIView viewWithBackground:[UIColor hex:0x0680FF alpha:1.0] alpha:1.0];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hw_online_slide"]];
    self.baseLineView = [UIView viewWithBackground:[UIColor hex:0x0680FF alpha:1.0] alpha:1.0];
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.imageView];
    [self addSubview:self.baseLineView];
}

- (void)initAutoLayout {
    [self.bottomView zk_AlignInner:ZK_AlignTypeCenterCenter referView:self size:CGSizeMake(60, 22) offset:CGPointZero];
    [self.imageView zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.bottomView size:CGSizeMake(35, 20) offset:CGPointZero];
    [self.baseLineView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self size:CGSizeMake([UIScreen wd_screenWidth], 1) offset:CGPointZero];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:touch.view.superview];
    CGFloat temph = self.h.constant;
     temph += point.y * -1;
    if (temph > 23) {
        self.h.constant = temph;
    }
}

@end


