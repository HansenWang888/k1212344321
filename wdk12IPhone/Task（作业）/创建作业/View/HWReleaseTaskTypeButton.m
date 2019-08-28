//
//  HWReleaseTaskTypeButton.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWReleaseTaskTypeButton.h"

@interface HWReleaseTaskTypeButton ()
///  选中的view
@property (nonatomic, strong) UIView *selectView;

@end

@implementation HWReleaseTaskTypeButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.selectView = [UIView viewWithBackground:[UIColor hex:0x47B757 alpha:1.0] alpha:1.0];
    self.selectCenterView = [UIView new];
    self.selectCenterView.backgroundColor = [UIColor whiteColor];
    self.titlelabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x262626 alpha:1.0] font:[UIFont systemFontOfSize:14] alpha:1.0];
    
    self.selectView.layer.cornerRadius = 9;
    self.selectView.layer.masksToBounds = true;
    self.selectCenterView.layer.cornerRadius = 7;
    self.selectCenterView.layer.masksToBounds = true;
    
    [self addSubview:self.selectView];
    [self.selectView addSubview:self.selectCenterView];
    [self addSubview:self.titlelabel];
}

- (void)initAutoLayout {
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
        make.width.height.offset(18);
    }];
    [self.selectCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.selectView);
        make.width.height.offset(14);
    }];
    [self.titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.selectView.mas_centerY);
    }];
}

- (void)setIsSel:(BOOL)isSel {
    _isSel = isSel;
    
    self.selectCenterView.backgroundColor = isSel ? [UIColor hex:0x47B757 alpha:1.0] : [UIColor whiteColor];
    [self.selectCenterView getBorderOnAllAroundWithColor:[UIColor whiteColor] Width:2];
    
}

@end
