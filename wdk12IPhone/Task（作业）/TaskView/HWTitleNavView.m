//
//  HWTitleNavView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTitleNavView.h"

@interface HWTitleNavView ()

@property (nonatomic, strong) UIView *baseLineView;
///  导航图标
@property (nonatomic, strong) UIImageView *navIcon;

@end

@implementation HWTitleNavView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.navIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hw_title_nav"]];
    self.currentTitleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0xFF4E00 alpha:1.0] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.countTitleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.topicNavButton = [UIButton new];
    self.baseLineView = [UIView viewWithBackground:[UIColor hex:0xF0F0F0 alpha:1.0] alpha:1.0];
    
    [self addSubview:self.countTitleLabel];
    [self addSubview:self.currentTitleLabel];
    [self addSubview:self.navIcon];
    [self addSubview:self.topicNavButton];
    [self addSubview:self.baseLineView];
}

- (void)initAutoLayout {
    [self.countTitleLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self size:CGSizeZero offset:CGPointZero];
    [self.currentTitleLabel zk_AlignHorizontal:ZK_AlignTypeCenterLeft referView:self.countTitleLabel size:CGSizeZero offset:CGPointZero];
    [self.navIcon zk_AlignInner:ZK_AlignTypeCenterRight referView:self size:CGSizeMake(20, 20) offset:CGPointMake(-10, 0)];
    [self.topicNavButton zk_AlignInner:ZK_AlignTypeCenterRight referView:self size:CGSizeMake(40, 40) offset:CGPointZero];
    [self.baseLineView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self size:CGSizeMake([UIScreen wd_screenWidth], 1) offset:CGPointZero];
}

@end
