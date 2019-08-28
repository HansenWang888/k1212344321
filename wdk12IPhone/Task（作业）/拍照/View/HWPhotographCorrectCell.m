//
//  HWPhotographCorrectCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPhotographCorrectCell.h"

@implementation HWPhotographCorrectCell

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
    [self.contentView addSubview:self.imageView];
    self.contentView.clipsToBounds = true;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)initAutoLayout {
    [self.imageView zk_Fill:self.contentView insets:UIEdgeInsetsZero];
}

@end
