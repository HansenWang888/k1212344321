//
//  HeadRosterView.m
//  wdk12IPhone
//
//  Created by cindy on 15/10/20.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "HeadRosterView.h"
#import "ClassModel.h"

@interface HeadRosterView ()
///  背景view
@property (nonatomic, strong) UIView *classBjView;
///  底色
@property (nonatomic, strong) UIView *subjectBjView;
///  班级label
@property (nonatomic, strong) UILabel *classLabel;
///  总人数及男女label
@property (nonatomic, strong) UILabel *countLabel;
///  班主任及科目label
@property (nonatomic, strong) UILabel * subLabel;

@end

@implementation HeadRosterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.classBjView = [UIView new];
    self.subjectBjView = [UIView new];
    self.classLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.countLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    self.subLabel   = [UILabel labelBackgroundColor:nil textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:16] alpha:1.0];
    
    [self addSubview:self.classBjView];
    [self addSubview:self.subjectBjView];
    [self.classBjView addSubview:self.classLabel];
    [self.classLabel addSubview:self.countLabel];
    [self.subjectBjView addSubview:self.subLabel];
    
    self.subLabel.numberOfLines = 0;
    self.subLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
    self.classBjView.backgroundColor = [UIColor whiteColor];
    self.subjectBjView.backgroundColor = [UIColor whiteColor];
}

- (void)initAutoLayout {
    [self.classBjView zk_AlignInner:ZK_AlignTypeTopLeft referView:self size:CGSizeMake([UIScreen wd_screenWidth], 63) offset:CGPointZero];
    [self.classLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.classBjView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.countLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.classLabel size:CGSizeZero offset:CGPointMake(0, 5)];
    [self.subjectBjView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.mas_equalTo(self.classBjView.mas_bottom).offset(10);
    }];
    [self.subLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.subjectBjView size:CGSizeZero offset:CGPointMake(10, 10)];
    
}

- (void)setValueForDataSource:(ClassModel *)data {
    self.classLabel.text = data.name;
    ;
    self.countLabel.text = [NSString stringWithFormat:@"%@：%tu    %@：%tu  %@：%tu",NSLocalizedString(@"总人数", nil), data.count, NSLocalizedString(@"男", nil), data.man, NSLocalizedString(@"女", nil), data.woman];
    self.subLabel.text = data.roleAndSubject; 
}

@end
