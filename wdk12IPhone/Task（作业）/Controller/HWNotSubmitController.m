//
//  HWNotSubmitController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWNotSubmitController.h"
#import "HWPhotographTaskController.h"
#import "HWNotOnlineViewController.h"
#import "HWTaskCollectionViewCell.h"
#import "HWPreviewViewController.h"
#import "HWOnlineViewController.h"
#import "HWStudentTask.h"
#import "StudentModel.h"
#import "HWTaskModel.h"

@interface HWNotSubmitController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation HWNotSubmitController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = false;
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.layout.minimumLineSpacing = 25;
    self.layout.minimumInteritemSpacing = 40;
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    CGFloat w = ([UIScreen wd_screenWidth] - 120) / 3;
    NSInteger type = [self.taskModel.fbdxlx integerValue];
    self.layout.itemSize = CGSizeMake(w, (type == 1 || type == 2) ? (70 + 19) : (70 - 15));
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HWTaskCollectionViewCell class] forCellWithReuseIdentifier:@"HWTaskCollectionViewCell"];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsZero];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWTaskCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HWTaskCollectionViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:self.data[indexPath.row]];
    if (![self.taskModel.fbdxlx isEqualToString:@"3"]) { // 班级
        cell.smallLabel.text = self.taskModel.fbdxmc;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    StudentModel *st = self.data[indexPath.row];
    if ([self.taskModel.zylx isEqualToString:@"1"]) { // 非在线作业
        HWNotOnlineViewController *vc = [HWNotOnlineViewController new];
        if (self.notOnlineData) {
            for (HWStudentTask *item in self.notOnlineData) {
                if ([item.xsID isEqualToString:st.id]) {
                    vc.studentTask = item;
                }
            }
        }
        vc.studentModel = st;
        vc.taskModel = self.taskModel;
        vc.isSubmit = false;
        [self.parentViewController.navigationController pushViewController:vc animated:true];
    } else if ([self.taskModel.zylx isEqualToString:@"2"]) { // 在线
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"该同学未提交作业,不能批改", nil)];
        return ;
    } else if ([self.taskModel.zylx isEqualToString:@""]) { // 预习
        HWPreviewViewController *vc = [HWPreviewViewController new];
        vc.isSubmit = false;
        vc.taskId = self.taskModel.zyID;
        [self.parentViewController.navigationController pushViewController:vc animated:true];
    } else if ([self.taskModel.zylx isEqualToString:@"3"]) { // 拍照
        // TODO: - 改到这里了
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"该同学未提交作业,不能批改", nil)];
        return ;
    }
}

- (void)setData:(NSArray *)data {
    _data = data;
    [self.collectionView reloadData];
}

@end
