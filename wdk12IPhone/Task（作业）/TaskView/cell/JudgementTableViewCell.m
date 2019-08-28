//
//  JudgementTableViewCell.m
//  wdk12IPhone
//
//  Created by 官强 on 17/6/1.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "JudgementTableViewCell.h"

@interface JudgementTableViewCell ()

///  基线
@property (nonatomic, strong) UIView *baselineView;
///  选中label
@property (nonatomic, strong) UILabel *selectLabel;


@end

@implementation JudgementTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    [self.contentView addSubview:self.serialNumButton];
    
    self.serialNumButton.layer.cornerRadius = 5;
    self.serialNumButton.layer.masksToBounds = true;
    self.serialNumButton.layer.borderWidth = 0.5;
    self.serialNumButton.userInteractionEnabled = false;
    self.serialNumButton.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)initAutoLayout {
    [self.serialNumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([System_Language isEqualToString:@"en"]) {
            make.left.offset(16);
        } else {
            make.left.offset(16);
        }
        make.top.offset(10);
        make.bottom.offset(-10);
        make.width.offset(100);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    if (isSelect) {
        self.serialNumButton.layer.borderColor = [UIColor clearColor].CGColor;
        [self.serialNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.serialNumButton.backgroundColor = [UIColor hex:0x62B76F alpha:1.0];
    } else {
        self.serialNumButton.layer.borderColor = [UIColor grayColor].CGColor;
        [self.serialNumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.serialNumButton.backgroundColor = [UIColor whiteColor];
    }
}
- (UIButton *)serialNumButton {
    if (!_serialNumButton) {
        _serialNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_serialNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_serialNumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _serialNumButton;
}

@end
