//
//  HWRightLabelTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWRightLabelTableViewCell.h"

@implementation HWRightLabelTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.rightLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    [self.contentView addSubview:self.rightLabel];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initAutoLayout {
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
