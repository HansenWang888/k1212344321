//
//  StudentIconCollectionViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/20.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "StudentIconCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "StudentModel.h"
#import <Masonry.h>

@implementation StudentIconCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.imgView = [UIImageView new];
    self.nameLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor hex:0x5B9718 alpha:1.0] font:[UIFont systemFontOfSize:15] alpha:1.0];
    
    [self addSubview:self.imgView];
    [self addSubview:self.nameLabel];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(60);
        make.height.offset(60);
        make.top.offset(10);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    self.imgView.clipsToBounds = true;
    self.backgroundColor = [UIColor clearColor];
    self.imgView.layer.cornerRadius = 30;
    self.imgView.layer.masksToBounds = true;
}

- (void)setValueForDataSource:(StudentModel *)data {
//    if (![data.iconImage isKindOfClass:[NSNull class]]) {
//        [self.imgView sd_setImageWithURL:[NSURL URLWithString:data.iconImage]];
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:@"http://www.bz55.com/uploads/allimg/121201/1-121201111T3-50.jpg"] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
//    }
    self.nameLabel.text = data.name;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
}

@end
