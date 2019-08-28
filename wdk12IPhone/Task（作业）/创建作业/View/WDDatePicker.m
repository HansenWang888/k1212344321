//
//  WDDatePicker.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/10/19.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDDatePicker.h"

@interface WDDatePicker ()

@property (strong, nonatomic) UIDatePicker *datePicker;

///  选择后面的view
@property (nonatomic, strong) UIView *selectView;
///  遮罩按钮
@property (nonatomic, strong) UIButton *shadeButton;
///  确定按钮
@property (nonatomic, strong) UIButton *trueButton;
///  取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation WDDatePicker

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.datePicker = [[UIDatePicker alloc] init];
    self.trueButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:[NSString stringWithFormat:@"%@  ", NSLocalizedString(@"确定", nil)] titleColor:[UIColor hex:0x0A60FE alpha:1.0] backgroundColor:nil];
    self.cancelButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"取消", nil)] titleColor:[UIColor hex:0x0A60FE alpha:1.0] backgroundColor:nil];
    self.shadeButton = [UIButton new];
    self.shadeButton.backgroundColor = [UIColor hex:0x000000 alpha:0.4];
    self.shadeButton.alpha = 0.0;
    self.datePicker.minimumDate = [NSDate date];
    self.selectView = [UIView viewWithBackground:[UIColor whiteColor] alpha:1.0];
    [self.shadeButton addTarget:self action:@selector(dismissTimeSelectView) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];

    self.cancelButton.tag = 1;
    [self.trueButton addTarget:self action:@selector(inputButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(inputButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor clearColor];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.shadeButton];
    [self addSubview:self.datePicker];
    [self addSubview:self.selectView];
    [self.selectView addSubview:self.trueButton];
    [self.selectView addSubview:self.cancelButton];
}

- (void)initAutoLayout {
    [self.shadeButton zk_Fill:self insets:UIEdgeInsetsZero];
    [self.datePicker zk_AlignInner:ZK_AlignTypeBottomLeft referView:self size:CGSizeMake([UIScreen wd_screenWidth], 180) offset:CGPointMake(0, 0)];
    [self.selectView zk_AlignVertical:ZK_AlignTypeTopLeft referView:self.datePicker size:CGSizeMake([UIScreen wd_screenWidth], 45) offset:CGPointZero];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(self.selectView);
    }];
    [self.trueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.selectView);
    }];
}

+ (WDDatePicker *)showTimeSelectWith:(UIView *)v date:(NSDate *)date {
    WDDatePicker *dv = [WDDatePicker new];
    dv.datePicker.date = date;
    [v addSubview:dv];
    dv.frame = v.bounds;
    dv.datePicker.transform = CGAffineTransformMakeTranslation(0, 300);
    dv.selectView.transform = CGAffineTransformMakeTranslation(0, 345);
    dv.shadeButton.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        dv.shadeButton.alpha = 1.0;
        dv.datePicker.transform = CGAffineTransformIdentity;
        dv.selectView.transform = CGAffineTransformIdentity;
    }];
    return dv;
}

- (void)dismissTimeSelectView {
    [UIView animateWithDuration:0.5 animations:^{
        self.datePicker.transform = CGAffineTransformMakeTranslation(0, 300);
        self.selectView.transform = CGAffineTransformMakeTranslation(0, 345);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//1取消 2确定
- (void)inputButtonClick:(UIButton *)sender {
    if (sender.tag == 1) { // 取消
        [self dismissTimeSelectView];
    } else { // 确定
        if (self.didTime) {
            self.didTime(self.datePicker.date);
            [self dismissTimeSelectView];
        }
    }
}

@end
