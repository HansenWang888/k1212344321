//
//  ModifyPasswordTableViewCell.m
//  Wd_Setting
//
//  Created by cindy on 15/10/16.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "ModifyPasswordTableViewCell.h"

@implementation ModifyPasswordTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.textField = [UITextField new];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:self.textField];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textField.secureTextEntry = true;
}

- (void)initAutoLayout {
    [self.textField zk_Fill:self.contentView insets:UIEdgeInsetsMake(10, 20, 10, 20)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

@end
