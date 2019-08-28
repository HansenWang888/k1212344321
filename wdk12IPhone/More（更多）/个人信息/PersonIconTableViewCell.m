//
//  PersonIconTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/10/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "PersonIconTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface PersonIconTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImage;

@end

@implementation PersonIconTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
   self.iconImage = [UIImageView new];
    [self.contentView addSubview:self.iconImage];
    self.iconImage.layer.cornerRadius = 66 * 0.5;
    self.iconImage.layer.masksToBounds = true;
    self.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)initAutoLayout {
    [self.iconImage zk_AlignInner:ZK_AlignTypeCenterRight referView:self.contentView size:CGSizeMake(66, 66) offset:CGPointMake(-20, 0)];
}

- (void)setValueForDataSource:(NSString *)data {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:data] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

@end
