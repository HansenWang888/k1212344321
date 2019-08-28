//
//  MOTrueTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MOTrueTableViewCell.h"

@implementation MOTrueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.trueButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"确定", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x4ABDB7 alpha:1.0]];
    [self.contentView addSubview:self.trueButton];
    self.trueButton.layer.cornerRadius = 3;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)initAutoLayout {
    [self.trueButton zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 40, 45) offset:CGPointZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}


@end
