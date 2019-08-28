//
//  HWPhotoCheckImageViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPhotoCheckImageViewCell.h"
#import <UIImageView+WebCache.h>

@interface HWPhotoCheckImageViewCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation HWPhotoCheckImageViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.scrollView = [UIScrollView new];
    self.imageView = [UIImageView new];
    self.imageView.userInteractionEnabled = true;
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.frame = CGRectMake(20, 0, [UIScreen wd_screenWidth], [UIScreen wd_screenHeight]);
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.scrollView addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.imageView addGestureRecognizer:tap1];
}

- (void)clickImage {
    [self.superViewController dismissViewControllerAnimated:true completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offy = (self.scrollView.bounds.size.height - self.imageView.frame.size.height) * 0.5;
    if (offy > 0) {
        self.scrollView.contentInset = UIEdgeInsetsMake(offy, 0, 0, 0);
    }
}

- (void)setImageViewWithData:(NSString *)imageStr {
    WEAKSELF(self);
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf resetScrollView];
        [weakSelf imagePostion:image];
        CGFloat offx = (self.scrollView.bounds.size.width - self.imageView.bounds.size.width) * 0.5;
        CGFloat offy = (self.scrollView.bounds.size.height - self.imageView.bounds.size.height) * 0.5;
        self.scrollView.contentInset = UIEdgeInsetsMake(offy, offx, 0, 0);
    }];
}


- (void)resetScrollView {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeZero;
    self.imageView.transform = CGAffineTransformIdentity;
}

- (void)imagePostion:(UIImage *)image {
    CGSize size = [self displaySize:image];
    if (self.bounds.size.height < size.height) { // 长图
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    } else {
        CGFloat y = (self.bounds.size.height - size.height) * 0.5;
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    }
}

- (CGSize)displaySize:(UIImage *)image {
    CGFloat scale = image.size.height / image.size.width;
    CGFloat h = self.scrollView.bounds.size.width * scale;
    return CGSizeMake(self.scrollView.bounds.size.width, h);
}

@end
