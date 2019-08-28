//
//  CheckPictureController.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/12/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "CheckPictureController.h"
#import <UIImageView+AFNetworking.h>
@interface CheckPictureController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollV;
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation CheckPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollV];
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
    if (self.picUrl.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.imageV setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.picUrl]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            NSLog(@"图片加载成功%@",image);
            [weakSelf calculationImageLocation:image];
            [weakSelf.activityView stopAnimating];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            WDULog(@"%@",error);
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"图片加载失败", nil)];
            [weakSelf.activityView stopAnimating];
        }];
    } else {
        self.imageV.image = self.image;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"关闭" , nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(8, 8, 45, 45);

    [self.view addSubview:btn];
}
- (void)btnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: UIScrollerView代理方法
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageV;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    //缩放结束后重新计算边距，缩放结束总是居中显示
    CGFloat offsetX = (CURRENT_DEVICE_SIZE.width - view.frame.size.width) * 0.5;
    //放大时,scrollV的X值不变
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat offsetY = (CURRENT_DEVICE_SIZE.height - view.frame.size.height) * 0.5;
    //放大时，scrollV的Y 值不变
    if (offsetY < 0){
        offsetY = 0;
    }
    //重新设置边距
    self.scrollV.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
}
- (void)calculationImageLocation:(UIImage *)img {
    
    if (img == nil) return;
    CGSize size = CGSizeMake(CURRENT_DEVICE_SIZE.width, CURRENT_DEVICE_SIZE.height - 64 * 2);
    //判断是否为长图
    if (img.size.height > CURRENT_DEVICE_SIZE.height) {
        self.imageV.frame = CGRectMake(0, 64, size.width, size.height);
        self.scrollV.contentSize = size;
    }else {
        //短图
        CGFloat y = (size.height - img.size.height) * 0.5;
        self.imageV.frame = CGRectMake(0, 0 , size.width, img.size.height);
        self.scrollV.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    }
    self.imageV.image = img;
}

- (UIScrollView *)scrollV {
    if (!_scrollV) {
        _scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CURRENT_DEVICE_SIZE.width, CURRENT_DEVICE_SIZE.height)];
        _scrollV.delegate = self;
        _imageV = [[UIImageView alloc] init];
        _scrollV.minimumZoomScale = 0.5;
        _scrollV.maximumZoomScale = 2.0;
        _imageV.backgroundColor = [UIColor orangeColor];
        _imageV.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick)];
        [_imageV addGestureRecognizer:tap];
        [_scrollV addSubview:_imageV];
    }
    return _scrollV;
}
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] init];
        _activityView.center = CGPointMake(CURRENT_DEVICE_SIZE.width * 0.5, CURRENT_DEVICE_SIZE.height * 0.5);
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_activityView startAnimating];
    }
    return _activityView;
}

- (void)dealloc {
    NSLog(@"8888");
}
@end
