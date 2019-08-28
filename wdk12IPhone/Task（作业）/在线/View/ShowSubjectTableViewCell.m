//
//  ShowSubjectTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ShowSubjectTableViewCell.h"
#import <Masonry.h>

@interface ShowSubjectTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ShowSubjectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

///  设置label
- (void)initView {
    self.titleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    [self.contentView addSubview:self.titleLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setValueForDataSource:(NSString *)data {
    self.titleLabel.text = data;
}

///  设置无选中效果
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

@end
