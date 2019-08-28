//
//  HWTaskListTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskListTableViewCell.h"
#import "HWTaskModel.h"
#import "WDMB.h"

@interface HWTaskListTableViewCell ()

///  作业标识
@property (nonatomic, strong) UILabel *identifierLabel;
///  作业类型
@property (nonatomic, strong) UILabel *typeLabel;
///  作业标题
@property (nonatomic, strong) UILabel *titleLabel;
///  发布对象
@property (nonatomic, strong) UILabel *releaseLabel;
///  布置时间
@property (nonatomic, strong) UILabel *startTimeLabel;
///  截止时间
@property (nonatomic, strong) UILabel *endTimeLabel;
///  提交人数
@property (nonatomic, strong) UILabel *submitLabel;
///  提交人数数量
@property (nonatomic, strong) UILabel *submitCountLabel;

@end

@implementation HWTaskListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.submitCountLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor hex:0xD4430A alpha:1.0] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.identifierLabel = [UILabel labelBackgroundColor:[UIColor hex:0xD4430A alpha:1.0] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.typeLabel      = [UILabel labelBackgroundColor:[UIColor whiteColor] textColor:[UIColor hex:0xFB4E09 alpha:1.0] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.titleLabel     = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.releaseLabel   = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.startTimeLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.endTimeLabel   = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.submitLabel    = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    self.bottomView     = [UIView viewWithBackground:[UIColor hex:0xEFEFEF alpha:1.0] alpha:1.0];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.submitCountLabel];
    [self.contentView addSubview:self.identifierLabel];
    [self.contentView addSubview:self.typeLabel];
    [self.contentView addSubview:self.releaseLabel];
    [self.contentView addSubview:self.startTimeLabel];
    [self.contentView addSubview:self.endTimeLabel];
    [self.contentView addSubview:self.submitLabel];
    [self.contentView addSubview:self.bottomView];
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.typeLabel.layer.borderColor = [UIColor hex:0xFB4E09 alpha:1.0].CGColor;
    self.typeLabel.layer.borderWidth = 1.0;
    self.typeLabel.layer.cornerRadius = 3;
    
    self.identifierLabel.layer.cornerRadius = 3;
    self.identifierLabel.layer.masksToBounds = true;
    self.identifierLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)initAutoLayout {
    [self.identifierLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeMake(24, 22) offset:CGPointMake(10, 9)];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.identifierLabel.mas_right).offset(10);
        make.height.offset(20);
        make.top.offset(10);
    }];
    [self.titleLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.releaseLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.titleLabel size:CGSizeZero offset:CGPointMake(0, 10)];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.mas_equalTo(self.releaseLabel.mas_bottom).offset(10);
    }];
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.mas_equalTo(self.startTimeLabel.mas_bottom).offset(10);
    }];
    [self.submitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(10);
        make.top.mas_equalTo(self.endTimeLabel.mas_bottom).offset(10);
    }];
    [self.submitCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.submitLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.submitLabel.mas_centerY);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.submitLabel.mas_bottom).offset(20);
        make.width.offset([UIScreen wd_screenWidth]);
        make.height.offset(10);
    }];
}

- (void)setValueForDataSource:(HWTaskModel *)data {
    self.identifierLabel.text = [data.zylx isEqualToString:@""] ? NSLocalizedString(@"预", nil) : @"";
    self.typeLabel.text = [NSString stringWithFormat:@"   %@   ", NSLocalizedString([WDMB MBToSubject][data.kmdm], nil)];
    [self.typeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.offset([self.identifierLabel.text isEqualToString:@""] ? 8 : 40);
        make.height.offset(20);
        make.top.offset(10);
    }];
    self.identifierLabel.alpha = ![self.identifierLabel.text isEqualToString:@""] ? 1.0 : 0.0;
    if ([self.identifierLabel.text isEqualToString:@""]) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@", self.typeLabel.text, (![data.zylx isEqualToString:@""] ? data.zymc : data.ksms)];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@   %@",self.identifierLabel.text, self.typeLabel.text, (![data.zylx isEqualToString:@""] ? data.zymc : data.ksms)];
    }
    
    //文字添加行间距
    NSString *titleString = self.titleLabel.text;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:8];
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [titleString length])];
    self.titleLabel.attributedText = attStr;
    
    self.releaseLabel.text = [NSString stringWithFormat:@"%@:%@%@", NSLocalizedString(@"发布对象", nil), data.njmc, data.fbdxmc];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"布置时间", nil), data.fbrq];
    self.endTimeLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"截止时间", nil), data.jzrq];
    if ([data.zylx isEqualToString:@""]) {
        [self.submitLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.startTimeLabel.mas_bottom).offset(10);
        }];
    }
    self.submitLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"提交人数", nil)];
    self.submitCountLabel.text = [NSString stringWithFormat:@"%d/%@", ([data.ytjs intValue] + [data.yfks intValue]), data.zrs];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

@end
