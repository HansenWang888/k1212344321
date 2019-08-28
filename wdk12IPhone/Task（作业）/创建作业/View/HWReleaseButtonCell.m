//
//  HWReleaseButtonCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWReleaseButtonCell.h"

@implementation HWReleaseButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.releaseButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"发布", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex: 0xFC6621 alpha:1.0]];
    [self.contentView addSubview:self.releaseButton];

}

- (void)initAutoLayout {
    [self.releaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.offset(40);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

@end
