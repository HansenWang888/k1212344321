//
//  RCImageCtrl.m
//  wdk12pad
//
//  Created by 老船长 on 16/2/17.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "RCImageCtrl.h"
#import <UIImageView+WebCache.h>
@interface RCImageCtrl ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end
@implementation RCImageCtrl

- (void)start {
    
    self.vc.view.backgroundColor = [UIColor blackColor];
    [self.vc.view addSubview:self.scrollView];
    [self.vc.view addSubview:self.activityView];
    if (self.path.length > 0) {
        [self.activityView startAnimating];
        __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.path] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf.activityView stopAnimating];
            if (error) {
                WDULog(@"%@",error);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"图片加载失败", nil)];
                return ;
            }
            [weakSelf calculationImageLocation:image];
            [weakSelf.activityView stopAnimating];
        }];
    }
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self.scrollView addGestureRecognizer:rotationGestureRecognizer];
    // Do any additional setup after loading the view.
    //双击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapsView:)];
    tap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:tap];
}
- (void)tapsView:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    view.transform = CGAffineTransformMakeScale(1.0, 1.0);
}
// 处理旋转手势

- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer  {
    
    UIView *view = rotationGestureRecognizer.view;
    
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        
        [rotationGestureRecognizer setRotation:0];
    }
    
}

//MARK: UIScrollerView代理方法
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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
    self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
}
- (CGSize)calculationScaleSizeImage:(UIImage *)img {
    if (img == nil) return CGSizeZero;
    CGSize size = [UIApplication sharedApplication].keyWindow.bounds.size;
    CGFloat scale = 0;
    CGFloat scaleWidth = 0;
    CGFloat scaleHeight = 0;
    if (img.size.width < size.width  && img.size.height < size.height) {
        
        scale = 1.0;
    } else if (img.size.width > size.width && img.size.height > size.height) {
        
        scale = MIN(size.width / img.size.width, size.height / img.size.height);
        
    } else if (img.size.width > size.width && img.size.height < size.height) {
        
        scale = size.width / img.size.width;
        
    } else if ( img.size.height > size.height && img.size.width < size.width) {
        
        scale = size.height / img.size.height;
    } else {
        
        scale = 1.0;
    }
    scaleWidth = img.size.width * scale;
    scaleHeight = img.size.height * scale;
    return CGSizeMake(scaleWidth, scaleHeight);
}
- (void)calculationImageLocation:(UIImage *)img {
    if (img == nil) return;
    if (img.images.count > 0) {
        //如果是gif 就显示gif的第一张图片
        self.imageView.image = img.images[0];
    } else {
        self.imageView.image = img;
    }
    CGSize viewSize = [self calculationScaleSizeImage:self.imageView.image];
    self.imageView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGFloat y = (self.vc.view.bounds.size.height - viewSize.height) * 0.5;
    CGFloat x = (self.vc.view.bounds.size.width - viewSize.width) * 0.5;
    self.scrollView.contentInset = UIEdgeInsetsMake(y, x, 0, 0);
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CURRENT_DEVICE_SIZE.width, CURRENT_DEVICE_SIZE.height)];
        _scrollView.delegate = self;
        _imageView = [[UIImageView alloc] init];
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.maximumZoomScale = 2.0;
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.userInteractionEnabled = YES;
        
        [_scrollView addSubview:_imageView];
    }
    return _scrollView;
}
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] init];
        _activityView.center = CGPointMake(CURRENT_DEVICE_SIZE.width * 0.5, CURRENT_DEVICE_SIZE.height * 0.5);
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [_activityView startAnimating];
    }
    return _activityView;
}
@end
