//
//  HMClasseExerciseCell.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClasseExerciseCell.h"
#import "HWClassesList.h"
#import <UIImageView+WebCache.h>


@interface HWClasseExerciseCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;


@end
@implementation HWClasseExerciseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fontLabel.text = @"\U0000e61b";
    self.accessoryLabel.text = @"\U0000e64e";
    // Initialization code
}
- (void)showDataWithClasseList:(HWClassesList *)list {
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:list.bjtp] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
    self.nameLable.text = list.bjmc;
    self.countLabel.text = list.xsrs;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
