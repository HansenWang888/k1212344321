//
//  HWPreviewDataController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPreviewDataController.h"
#import "HWDataCollectionViewCell.h"
#import "ResourceVCViewController.h"
#import "HWTaskPreviewData.h"

@interface HWPreviewDataController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  提示label
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation HWPreviewDataController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor randomColor];
    [self initView];
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = false;

    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.layout.minimumLineSpacing = 20;
    self.layout.minimumInteritemSpacing = 20;
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    CGFloat w = ([UIScreen wd_screenWidth] - 80) / 3;

    self.layout.itemSize = CGSizeMake(w, w);
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HWDataCollectionViewCell class] forCellWithReuseIdentifier:@"HWDataCollectionViewCell"];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsZero];
    
    self.promptLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:0];
    [self.view addSubview:self.promptLabel];
    self.promptLabel.text = NSLocalizedString(@"该作业未添加附件", nil);
    [self.promptLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.view size:CGSizeZero offset:CGPointZero];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWDataCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HWDataCollectionViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:self.data[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    HWTaskPreviewData *model = self.data[indexPath.row];
    ResourceVCViewController* vc = [[ResourceVCViewController alloc] initWithPath:model.zldz ConverPath:model.zldznew Type:model.wjgs Name:model.zlmc];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
}

- (void)setData:(NSArray *)data {
    _data = data;
    if (self.data.count > 0) {
        [self.collectionView reloadData];
        self.promptLabel.alpha = 0.0;
    } else {
        self.promptLabel.alpha = 1.0;
    }
}

@end
