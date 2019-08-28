//
//  HWPhotoDetailViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 2017/7/11.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "HWPhotoDetailViewController.h"
#import "HWPhotographModel.h"
#import <UIImageView+WebCache.h>
#import "PhotoToolBar.h"
#import <WDToolsManager/WDToolsManager.h>
#import "MediaOBJ.h"
#import "WDHTTPManager.h"

@interface HWPhotoDetailViewController ()<UIScrollViewDelegate,UITabBarDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) PhotoToolBar *photoBar;

@property (nonatomic, assign) BOOL isFeedBack;

@end

@implementation HWPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addUI];
}

- (void)addUI {

    self.isFeedBack = self.model.pgfjList.count;
    
    self.scrollView=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    
    [self setImageWithIsOri:!self.isFeedBack];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage)]];
    [self.scrollView addSubview:self.imageView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen wd_screenWidth], 64)];
    self.topView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:self.topView];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = self.topView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor hex:0x6B6B6B alpha:0.8].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    [self.topView.layer addSublayer:gradientLayer];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 25, 30, 30)];
    [button setImage:[UIImage imageNamed:@"photo_back"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(back) forControlEvents:(UIControlEventTouchUpInside)];
    [self.topView addSubview:button];
    
    self.photoBar = [[PhotoToolBar alloc] initWithFrame:CGRectMake(0, [UIScreen wd_screenHeight]-49, [UIScreen wd_screenWidth], 49)];
    self.photoBar.delegate = self;
    self.photoBar.isFeedBack = self.isFeedBack;
    [self.view addSubview:self.photoBar];
}

- (void)setImageWithIsOri:(BOOL)isOri {
    NSString *imageUrl = @"";
    if (isOri) {//原图
        imageUrl = self.model.xsfjdz;
    }else {//反馈图
        imageUrl = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL, [[self.model.pgfjList firstObject] fjdz]];
    }
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
}

#pragma mark -- UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [tabBar.items indexOfObject:item];
    
    if (index == 0) {
        
        if (self.isFeedBack) {//清除反馈
            self.model.pgfjList = @[].mutableCopy;
            if (self.saveBack) {
                self.saveBack(self.model);
            }
            [self back];
        }else {
            [self pushToDelineateVC];
        }
        
    }else if (index == 1) {
        
        [self pushToDelineateVC];
        
    }else if (index == 2) {//原图
        [self setImageWithIsOri:YES];
    }
}

- (void)pushToDelineateVC {
    //下载图片
    WEAKSELF(self);
    [SVProgressHUD show];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.model.xsfjdz] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (image) {
                
                WDDelineateVC *delineVC = [WDDelineateVC delineateVeticalVCWithImage:image];
                __weak typeof(delineVC) deline = delineVC;

                delineVC.finishedBlock = ^(UIImage *imageB,WDDelineateVC *vc) {
                    
                    if (imageB) {
                        [weakSelf uploadAttachmentWithData:UIImageJPEGRepresentation(imageB, 1) type:@"png"];
                        weakSelf.imageView.image = imageB;
                    }
                    [deline dismissViewControllerAnimated:YES completion:nil];
                };
                [weakSelf presentViewController:delineVC animated:YES completion:nil];
            }
        });
    }];
}

//上传图片
- (void)uploadAttachmentWithData:(NSData *)data type:(NSString *)type {
    
    MediaOBJ *obj = [MediaOBJ new];
    obj.mediaType = type;
    obj.mediaData = data;
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger] uploadWithAdjunctFileWithData:@[obj] progressBlock:nil finished:^(NSDictionary *data) {
        if (data) {
            NSDictionary *dcit = [data[@"msgObj"] firstObject];
            HWPhotographModel *model = [HWPhotographModel new];
            model.fjdz = dcit[@"fileId"];
            model.fjmc = dcit[@"fileName"];
            model.fjdx = dcit[@"fileSize"];
            model.fjgs = dcit[@"fileExtName"];
            weakSelf.model.pgfjList = @[model].mutableCopy;
            if (self.saveBack) {
                self.saveBack(self.model);
            }
            [self back];
        }else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"上传失败！", nil)];
        }
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;//要放大的视图
}

- (void)tapImage {

    if (self.topView.y == 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.topView.y = -64;
            self.photoBar.y = [UIScreen wd_screenHeight];
        }];
    }else {
        [UIView animateWithDuration:0.15 animations:^{
            self.topView.y = 0;
            self.photoBar.y = [UIScreen wd_screenHeight]-49;
        }];
    }
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
