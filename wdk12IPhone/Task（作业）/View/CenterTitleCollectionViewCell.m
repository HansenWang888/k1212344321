//
//  CenterTitleCollectionViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/2.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "CenterTitleCollectionViewCell.h"
#import "HWSubject.h"

@interface CenterTitleCollectionViewCell ()

@end

@implementation CenterTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x999999 alpha:1.0] font:[UIFont systemFontOfSize:17] alpha:1.0];
        self.rightView = [UIView new];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.rightView];
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.left.right.equalTo(self.contentView);
        }];
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.contentView);
            make.width.offset(1);
        }];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 2;
        self.label.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setValueForDataSource:(HWSubject *)data {
    self.label.text = data.subjectCH;
    self.contentView.backgroundColor = data.isSel ? [UIColor hex:0x4DB858 alpha:1.0] : [UIColor whiteColor];
    self.label.textColor = data.isSel ? [UIColor whiteColor] : [UIColor hex:0x878787 alpha:1.0];
}

@end
