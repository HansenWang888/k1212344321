//
//  HWExplainTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWExplainTableViewHeaderView.h"

@interface HWExplainTableViewHeaderView ()

@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HWExplainTableViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.baseView = [UIView viewWithBackground:[UIColor grayColor] alpha:1.0];
    self.titleLabel = [UILabel labelBackgroundColor:[UIColor whiteColor] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    
    [self.contentView addSubview:self.baseView];
    [self.contentView addSubview:self.titleLabel];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)initAutoLayout {
    [self.baseView zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 20, 1) offset:CGPointZero];
    [self.titleLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.contentView size:CGSizeZero offset:CGPointZero];
}

- (void)setValueForDataSource:(NSString *)data {
    self.titleLabel.text = data;
}

@end
