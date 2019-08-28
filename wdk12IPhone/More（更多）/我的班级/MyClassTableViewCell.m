//
//  MyClassTableViewCell.m
//  Wd_Setting
//
//  Created by cindy on 15/10/16.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "MyClassTableViewCell.h"
#import "ClassModel.h"

@interface MyClassTableViewCell ()

///  班级名称label
@property (nonatomic, strong) UILabel *nameLabel;
///  来源label如花名册
@property (nonatomic, strong) UILabel *fromLabel;

@end

@implementation MyClassTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.nameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.roleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    self.fromLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.roleLabel];
    [self.contentView addSubview:self.fromLabel];
    self.roleLabel.numberOfLines = 0;
    self.roleLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
}

- (void)initAutoLayout {
    [self.nameLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.roleLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.nameLabel size:CGSizeZero offset:CGPointMake(0, 10)];
    [self.fromLabel zk_AlignInner:ZK_AlignTypeTopRight referView:self.contentView size:CGSizeZero offset:CGPointMake(-10, 10)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueForDataSource:(ClassModel *)data {
    self.nameLabel.text = data.name;
    self.fromLabel.text = NSLocalizedString(@"花名册", nil);
    self.roleLabel.text = data.roleAndSubject;// data.subjects.length > 0 ? [NSString stringWithFormat:@"%@  科目:%@", data.role, data.subjects] : [NSString stringWithFormat:@"%@", data.role];
    [self.contentView layoutIfNeeded];
}

@end
