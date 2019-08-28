//
//  PresentatiobController.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/24.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "PresentatiobController.h"

@interface PresentatiobController ()
@property (nonatomic, strong) UIView *duumyV;

@end

@implementation PresentatiobController

- (UIView *)duumyV {

    if (!_duumyV) {
        _duumyV = [[UIView alloc] init];
        _duumyV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        //增加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDuumyView)];
        [_duumyV addGestureRecognizer:tap];
    }
    return _duumyV;
}
- (void)dismissDuumyView {

    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
//布局容器视图
- (void)containerViewWillLayoutSubviews {

    [super containerViewWillLayoutSubviews];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.duumyV.frame = rect;
    [self.containerView insertSubview:self.duumyV atIndex:0];
    //做转场的View的尺寸
    self.presentedView.frame = self.rect;
}

@end
