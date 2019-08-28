//
//  HWTimerTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWTimerTableViewCell.h"
#import "HWTaskTimerModel.h"

@interface HWTimerTableViewCell ()

///  名称
@property (nonatomic, strong) UILabel *nameLabel;

///  基线
@property (nonatomic, strong) UIView *baseLineView;
///  时间说明
@property (nonatomic, strong) UILabel *timeExplainLabel;
///  时间
@property (nonatomic, strong) UILabel *timeLabel;
///  右边箭头label
@property (nonatomic, strong) UILabel *rightLabel;
///  底部view
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation HWTimerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.nameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.delButton = [UIButton buttonWithImageName:@"" title:@"\U0000e624" font:[UIFont fontWithName:@"iconfont" size:24] titleColor:[UIColor hex:0xFB5F22 alpha:1.0]];
    self.baseLineView = [UIView viewWithBackground:[UIColor grayColor] alpha:0.7];
    self.timeExplainLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.timeLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.rightLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont fontWithName:@"iconfont" size:24] alpha:1.0];
    self.bottomView = [UIView viewWithBackground:[UIColor hex:0xEFEFEF alpha:1.0] alpha:1.0];
    self.selTimeButton = [UIButton new];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.delButton];
    [self.contentView addSubview:self.baseLineView];
    [self.contentView addSubview:self.timeExplainLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.bottomView];
    [self.contentView addSubview:self.selTimeButton];
    
    self.nameLabel.text = @"三年级一班";
    self.timeExplainLabel.text = NSLocalizedString(@"发布时间:", nil);
    self.timeLabel.text = @"2016-07-18 00:00";
    self.rightLabel.text = @"\U0000e60c";
}

- (void)initAutoLayout {
    [self.nameLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.delButton zk_AlignInner:ZK_AlignTypeTopRight referView:self.contentView size:CGSizeZero offset:CGPointMake(-10, 3)];
    [self.baseLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10);
        make.left.offset(10);
        make.right.offset(-10);
        make.height.offset(0.5);
    }];
    [self.timeExplainLabel zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, -20)];
    [self.rightLabel zk_AlignInner:ZK_AlignTypeBottomRight referView:self.contentView size:CGSizeZero offset:CGPointMake(-10, -20)];
    [self.timeLabel zk_AlignHorizontal:ZK_AlignTypeCenterLeft referView:self.rightLabel size:CGSizeZero offset:CGPointMake(-10, 0)];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.mas_equalTo(self.timeExplainLabel.mas_bottom).offset(10);
    }];
    [self.selTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.offset(48);
    }];
}

- (void)setValueForDataSource:(HWTaskTimerModel *)data {
    self.nameLabel.text = data.name;
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: data.date];
    NSDate *date = [data.date dateByAddingTimeInterval:interval];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd hh:mm";
    dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    NSString *time = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:date]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", time];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
