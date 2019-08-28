//
//  HWSingleTestAnswerCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWSingleTestAnswerCell.h"

@interface HWSingleTestAnswerCell ()

///  顶部view
@property (nonatomic, strong) UIView *topView;
///  颜色view
@property (nonatomic, strong) UIView *colorView;
///  标题
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation HWSingleTestAnswerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.topView = [UIView viewWithBackground:[UIColor hex:0xEFEFEF alpha:1.0] alpha:1.0];
    self.colorView = [UIView viewWithBackground:[UIColor hex:0x2F9B8C alpha:1.0] alpha:1.0];
    self.titleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.colorView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    
    self.titleLabel.text = NSLocalizedString(@"答案内容", nil);
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
}

- (void)initAutoLayout {
    [self.topView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth], 10) offset:CGPointZero];
    [self.colorView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeMake(6, 20) offset:CGPointMake(10, 20)];
    [self.titleLabel zk_AlignHorizontal:ZK_AlignTypeCenterRight referView:self.colorView size:CGSizeZero offset:CGPointMake(10, 0)];
    [self.contentLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.colorView size:CGSizeZero offset:CGPointMake(0, 10)];
}

//- (void)setValueForDataSource:(<#WDCourseList#> *)data {
//    
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
