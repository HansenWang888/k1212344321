//
//  HWOnlieStudentCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWOnlieStudentCell.h"
#import <UIImageView+WebCache.h>
#import "StudentModel.h"
#import "HWTaskModel.h"

@interface HWOnlieStudentCell ()

///  头像
@property (nonatomic, strong) UIImageView *iconImage;
///  名称
@property (nonatomic, strong) UILabel *nameLabel;
///  班级名称
@property (nonatomic, strong) UILabel *classNameLabel;

///  分值
@property (nonatomic, strong) UILabel *scoreLabel;
///  baseLine
@property (nonatomic, strong) UIView *baseLineView;

@end

@implementation HWOnlieStudentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultAvatar"]];
    self.nameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.classNameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x535353 alpha:1.0] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.numLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0xFF4E00 alpha:1.0] font:[UIFont systemFontOfSize:18] alpha:1.0];
    self.scoreLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    self.baseLineView = [UIView viewWithBackground:[UIColor blackColor] alpha:0.4];
    
    [self.contentView addSubview:self.iconImage];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.classNameLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.scoreLabel];
    [self.contentView addSubview:self.baseLineView];
    
    self.nameLabel.text = @"";
    self.classNameLabel.text = @"";
    self.numLabel.text = @"0";
    self.scoreLabel.text = NSLocalizedString(@"分", nil);
    
    self.iconImage.layer.cornerRadius = 25;
    self.iconImage.layer.masksToBounds = true;
}

- (void)initAutoLayout {
    [self.iconImage zk_AlignInner:ZK_AlignTypeCenterLeft referView:self.contentView size:CGSizeMake(50, 50) offset:CGPointMake(10, 0)];
    [self.nameLabel zk_AlignHorizontal:ZK_AlignTypeTopRight referView:self.iconImage size:CGSizeZero offset:CGPointMake(10, 0)];
    [self.classNameLabel zk_AlignHorizontal:ZK_AlignTypeBottomRight referView:self.iconImage size:CGSizeZero offset:CGPointMake(10, 0)];
    [self.scoreLabel zk_AlignInner:ZK_AlignTypeCenterRight referView:self.contentView size:CGSizeZero offset:CGPointMake(-30, 0)];
    [self.numLabel zk_AlignHorizontal:ZK_AlignTypeCenterLeft referView:self.scoreLabel size:CGSizeZero offset:CGPointMake(-10, 0)];
    [self.baseLineView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 20, 0.5) offset:CGPointZero];
}

- (void)setValueForDataSource:(StudentModel *)data {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:data.iconImage] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    self.nameLabel.text = data.name;
    self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", self.taskModel.njmc, self.taskModel.fbdxmc];
}

- (void)setValueForDataSource:(StudentModel *)data type:(BOOL)type xtIndex:(NSInteger)index stID:(NSString *)stID {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:data.iconImage] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    self.nameLabel.text = data.name;
    self.classNameLabel.text = [NSString stringWithFormat:@"%@%@", self.taskModel.njmc, self.taskModel.fbdxmc];
    self.numLabel.text = @"0";
    for (NSDictionary *item in data.snwerArray) {
        if (type) { // 小题
            if ([item[@"xtID"] isEqualToString:stID]) {
                self.numLabel.text = [NSString stringWithFormat:@"%@", item[@"df"] ? item[@"df"] : @""];
                break;
            }
        } else {
            if ([item[@"stID"] isEqualToString:stID]) {
                self.numLabel.text = [NSString stringWithFormat:@"%@", item[@"df"] ? item[@"df"] : @""];
                break;
            }
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

@end
