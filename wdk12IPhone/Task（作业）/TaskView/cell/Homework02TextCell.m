//
//  GqpFilingTableViewCell.m
//  wdk12pad
//
//  Created by 王振坤 on 16/7/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "Homework02TextCell.h"

@interface Homework02TextCell ()

@property (nonatomic, strong) UIView *baseLine;

@end

@implementation Homework02TextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.textField = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.numLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.baseLine = [UIView viewWithBackground:[UIColor blackColor] alpha:0.5];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.textField];
    [self.textField addSubview:self.baseLine];
    self.numLabel.text = @"1.";
}

- (void)initAutoLayout {
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(10);
        make.width.offset(10);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.numLabel.mas_right).offset(10);
        make.top.offset(10);
        make.right.offset(-10);
        make.height.offset(30);
    }];
    [self.baseLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.textField);
        make.height.offset(0.5);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setValueForDataSource:(NSString *)data {
    
    self.textField.text = data;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}




@end
