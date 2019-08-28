//
//  NotOnlineCollectionViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/11.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "NotOnlineCollectionViewCell.h"
#import "HWAccessoryModel.h"
#import <Masonry.h>
#import "WDMB.h"

@interface NotOnlineCollectionViewCell ()

///  图片
@property (nonatomic, strong) UIImageView *imageView;
///  标题
@property (nonatomic, strong) UILabel *titlelabel;

@end

@implementation NotOnlineCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutolayout];
    }
    return self;
}

- (void)initView {
    self.imageView = [UIImageView new];
    self.titlelabel = [UILabel labelBackgroundColor:nil textColor:nil font:[UIFont systemFontOfSize:10] alpha:1.0];
    self.delButton = [UIButton buttonWithImageName:@"icon_error" title:@"" font:nil titleColor:nil];
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titlelabel];
    [self.contentView addSubview:self.delButton];
    
    self.imageView.image = [UIImage imageNamed:@"file_doc"];
    self.titlelabel.numberOfLines = 0;
    self.titlelabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.delButton.alpha = 0.0;
}

- (void)initAutolayout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.offset(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-40);
    }];
    [self.titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.mas_equalTo(self.imageView.mas_bottom);
    }];
    [self.delButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.right.offset(-10);
        make.width.height.offset(25);
    }];
}

- (void)setData:(HWAccessoryModel *)data {
    _data = data;

    self.imageView.image = [UIImage imageNamed:[[WDMB MBToAdjunctImage] valueForKey:[data.fjgs uppercaseString]]];
    self.titlelabel.text = data.fjmc;
}


@end
