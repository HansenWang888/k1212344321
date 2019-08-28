//
//  HWTaskTypeTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWTaskTypeTableViewCell.h"
#import "HWReleaseTaskTypeButton.h"

@interface HWTaskTypeTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) HWReleaseTaskTypeButton *taskButton;

@property (nonatomic, strong) HWReleaseTaskTypeButton *previewButton;

@property (nonatomic, strong) HWReleaseTaskTypeButton *reviewButton;

@property (nonatomic, weak) HWReleaseTaskTypeButton *tempButton;

@end

@implementation HWTaskTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.titleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x2F9B8C alpha:1.0] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.taskButton = [HWReleaseTaskTypeButton new];
    self.previewButton = [HWReleaseTaskTypeButton new];
    self.reviewButton = [HWReleaseTaskTypeButton new];
    self.titleLabel.text = [NSString stringWithFormat:@"   %@:", NSLocalizedString(@"类型", nil)];
    self.taskButton.titlelabel.text = NSLocalizedString(@"作业", nil);
    self.previewButton.titlelabel.text = NSLocalizedString(@"预习", nil);
    self.reviewButton.titlelabel.text = NSLocalizedString(@"复习", nil);
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.taskButton];
    [self.contentView addSubview:self.previewButton];
    [self.contentView addSubview:self.reviewButton];
    self.taskButton.isSel = true;
    [self.taskButton addTarget:self action:@selector(changeSelectStatudWith:) forControlEvents:UIControlEventTouchUpInside];
    [self.previewButton addTarget:self action:@selector(changeSelectStatudWith:) forControlEvents:UIControlEventTouchUpInside];
    [self.reviewButton addTarget:self action:@selector(changeSelectStatudWith:) forControlEvents:UIControlEventTouchUpInside];
    self.tempButton = self.taskButton;
    
    self.taskButton.tag = 1;
    self.previewButton.tag = 2;
    self.reviewButton.tag = 3;
}

- (void)changeSelectStatudWith:(HWReleaseTaskTypeButton *)sender {
    self.tempButton.isSel = false;
    sender.isSel = !sender.isSel;
    self.tempButton = sender;
    
    if (self.didSelType) {
        self.didSelType(sender.tag);
    }
}

- (void)initAutoLayout {
    [self.contentView zk_HorizontalTile:@[self.taskButton, self.previewButton, self.reviewButton] insets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.taskButton.centerY);
        make.left.offset(0);
    }];
}

- (void)setValueForDataSource:(NSString *)data {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

@end
