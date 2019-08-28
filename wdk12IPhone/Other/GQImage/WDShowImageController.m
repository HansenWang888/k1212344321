//
//  WDShowImageController.m
//  是生死
//
//  Created by 官强 on 2017/8/17.
//  Copyright © 2017年 guanqiang. All rights reserved.
//

#import "WDShowImageController.h"
#import "WDShowImageCollectionCell.h"

@interface WDShowImageController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSArray   *imageUrlArr;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, assign) BOOL isLocal;

@end


@implementation WDShowImageController

+ (BOOL)isImage:(NSString *)string {
    if ([string isEqualToString:@"PNG"] || [string isEqualToString:@"JPG"] || [string isEqualToString:@"GIF"] || [string isEqualToString:@"JPEG"] || [string isEqualToString:@"png"] || [string isEqualToString:@"jpg"] || [string isEqualToString:@"gif"] || [string isEqualToString:@"jpeg"]) {
        return YES;
    }else {
        return NO;
    }
}

+ (UIViewController *)initImageVC:(NSString *)title imageUrlArray:(NSArray *)imageArr index:(NSInteger)index {
    
    WDShowImageController *vc = [WDShowImageController new];
    vc.imageUrlArr = imageArr;
    vc.index = index;
    vc.titleStr = title;
    vc.isLocal = NO;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:41/255.0 green:138/255.0 blue:109/255.0 alpha:1.0];
    return nav;
}

+ (UIViewController *)initLocalImageVC:(NSString *)title imageUrlArray:(NSArray *)imageArr index:(NSInteger)index {
    WDShowImageController *vc = [WDShowImageController new];
    vc.imageUrlArr = imageArr;
    vc.index = index;
    vc.titleStr = title;
    vc.isLocal = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:41/255.0 green:138/255.0 blue:109/255.0 alpha:1.0];
    return nav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftBtn setTitle:@"完成" forState:(UIControlStateNormal)];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [leftBtn addTarget:self action:@selector(backForwd) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.title = self.titleStr.length ? self.titleStr : @"";
    
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    [self.collectionView registerClass:[WDShowImageCollectionCell class] forCellWithReuseIdentifier:@"WDShowImageCollectionCell"];
    self.collectionView.pagingEnabled = true;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width*self.index, 64)];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageUrlArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WDShowImageCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"WDShowImageCollectionCell" forIndexPath:indexPath];
    if (self.isLocal) {
        [cell setCellWithImage:self.imageUrlArr[indexPath.row]];
    }else {
        NSString *str = self.imageUrlArr[indexPath.row];
        [cell setImageViewWithUrl:str];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WDShowImageCollectionCell *CELLL = (WDShowImageCollectionCell *)cell;
    CELLL.imageV.transform = CGAffineTransformIdentity;
    
}


- (void)backForwd {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
