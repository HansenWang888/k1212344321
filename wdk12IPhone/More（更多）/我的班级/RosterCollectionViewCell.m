//
//  RosterCollectionViewCell.m
//  wdk12IPhone
//
//  Created by cindy on 15/10/20.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "RosterCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "StudentModel.h"

@interface RosterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@end

@implementation RosterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [UIImageView new];
        self.label = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
        }];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.offset(20);
        }];
        
        self.label.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setValueForDataSource:(StudentModel *)data {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:data.iconImage] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
    self.label.text = data.name;
}

@end
