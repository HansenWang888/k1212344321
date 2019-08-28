//
//  WDShowImageCollectionCell.m
//  是生死
//
//  Created by 官强 on 2017/8/17.
//  Copyright © 2017年 guanqiang. All rights reserved.
//

#import "WDShowImageCollectionCell.h"
#import <UIImageView+WebCache.h>

@interface WDShowImageCollectionCell ()<UIGestureRecognizerDelegate>

@end

@implementation WDShowImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.imageV = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.imageV.userInteractionEnabled = true;
    self.imageV.multipleTouchEnabled = true;
    self.imageV.contentMode = UIViewContentModeScaleToFill;
    self.imageV.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageV];
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    [self.imageV addGestureRecognizer:pinch];
    UIRotationGestureRecognizer *rotation =[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationAction:)];
    [self.imageV addGestureRecognizer:rotation];
    pinch.delegate = self;
    rotation.delegate = self;
    
}

- (void)setImageViewWithUrl:(NSString *)imageStr {
    [SVProgressHUD show];
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        if (image) {
            
            CGSize siz = [self getSize:image.size];
            
            self.imageV.frame = CGRectMake(0, 0, siz.width, siz.height);
            self.imageV.centerX = self.contentView.centerX;
            self.imageV.centerY = self.contentView.centerY;
            self.imageV.image = image;
            self.imageV.contentMode = UIViewContentModeScaleToFill;
        }
    }];
    
}

- (void)setCellWithImage:(UIImage *)image {
    if (image) {
        
        CGSize siz = [self getSize:image.size];
        
        self.imageV.frame = CGRectMake(0, 0, siz.width, siz.height);
        self.imageV.centerX = self.contentView.centerX;
        self.imageV.centerY = self.contentView.centerY;
        self.imageV.image = image;
        self.imageV.contentMode = UIViewContentModeScaleToFill;
    }
}

- (CGSize)getSize:(CGSize)orSize {
    
    CGFloat wid = orSize.width;
    CGFloat hei = orSize.height;
    
    CGFloat scale = wid/hei;
    
    
    if (wid < CGRectGetWidth(self.contentView.frame)) {
        wid = wid;
        
        if (hei < CGRectGetHeight(self.contentView.frame)) {
            hei = hei;
        }else {
            hei = CGRectGetHeight(self.contentView.frame);
        }
        
    }else {
        wid = CGRectGetWidth(self.contentView.frame);
        hei = wid/scale;
    }
    
    return [self getHeigSize:CGSizeMake(wid, hei)];
}

- (CGSize)getHeigSize:(CGSize)orSize {
    
    CGFloat wid = orSize.width;
    CGFloat hei = orSize.height;
    
    CGFloat scale = wid/hei;
    
    
    if (hei < CGRectGetHeight(self.contentView.frame)) {
        hei = hei;
        wid = wid;
    }else {
        hei = CGRectGetHeight(self.contentView.frame);
        wid = hei*scale;
    }
    
    return CGSizeMake(wid, hei);
}

-(void)pinchAction:(UIPinchGestureRecognizer *)pinch
{
    UIImageView *imageView = (UIImageView *)pinch.view;
    if (!imageView) {
        return ;
    }
    
    imageView.transform = CGAffineTransformScale(imageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}


-(void)rotationAction:(UIRotationGestureRecognizer *)rote
{
    UIImageView *imageView = (UIImageView *)rote.view;
    if (!imageView) {
        return ;
    }
    
    imageView.transform = CGAffineTransformRotate(imageView.transform, rote.rotation);
    rote.rotation = 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
