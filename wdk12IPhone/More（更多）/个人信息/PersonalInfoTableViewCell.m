//
//  PersonalInfoTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/18.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "PersonalInfoTableViewCell.h"

@interface PersonalInfoTableViewCell ()

///  信息值
@property (nonatomic, strong) UILabel *infoValue;

@end

@implementation PersonalInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.infoValue = [UILabel labelBackgroundColor:nil textColor:[UIColor darkGrayColor] font:nil alpha:1.0];
        [self.contentView addSubview:self.infoValue];
        [self.infoValue zk_AlignInner:ZK_AlignTypeCenterRight referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 220, 30) offset:CGPointZero];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.infoValue.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setValueForDataSource:(NSString *)data {
    self.infoValue.text = data;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

@end
