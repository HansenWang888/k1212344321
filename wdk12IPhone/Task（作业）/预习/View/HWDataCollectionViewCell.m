//
//  HWDataCollectionViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWDataCollectionViewCell.h"
#import "HWTaskPreviewData.h"
#import "WDMB.h"

@interface HWDataCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation HWDataCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.imageView = [UIImageView new];
    self.nameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.nameLabel];
    
    self.imageView.image = [UIImage imageNamed:@"holdHeadImage"];
    self.nameLabel.text = @"";
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.adjustsFontSizeToFitWidth = true;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)initAutoLayout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.bottom.offset(-20);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.mas_equalTo(self.imageView.mas_bottom);
    }];
}

- (void)setValueForDataSource:(HWTaskPreviewData *)data {
    self.imageView.image = [UIImage imageNamed:[WDMB.MBToAdjunctImage valueForKey:data.wjgs]];
    self.nameLabel.text = [NSString stringWithFormat:@"%@", data.zlmc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
