//
//  HWTaskCollectionViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "StudentModel.h"

@interface HWTaskCollectionViewCell ()

///  头像
@property (nonatomic, strong) UIImageView *imageView;
///  名称
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation HWTaskCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.imageView = [UIImageView new];
    self.nameLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.smallLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:14] alpha:1.0];
    
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.smallLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.smallLabel];
    
    self.imageView.layer.cornerRadius = 25;
    self.imageView.layer.masksToBounds = true;
}

- (void)initAutoLayout {
    [self.imageView zk_AlignInner:ZK_AlignTypeTopCenter referView:self.contentView size:CGSizeMake(50, 50) offset:CGPointZero];
    [self.nameLabel zk_AlignVertical:ZK_AlignTypeBottomCenter referView:self.imageView size:CGSizeZero offset:CGPointMake(0, 5)];
    [self.smallLabel zk_AlignVertical:ZK_AlignTypeBottomCenter referView:self.nameLabel size:CGSizeMake(([UIScreen wd_screenWidth] - 60)/3.0, 20) offset:CGPointMake(0, 5)];
}

- (void)setValueForDataSource:(StudentModel *)data {
    
    self.nameLabel.text = data.name;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:data.iconImage] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
