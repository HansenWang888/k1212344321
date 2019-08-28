//
//  RosterViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/10/19.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "RosterViewController.h"
#import "MOExitClassViewController.h"
#import "RosterCollectionViewCell.h"
#import "RosterViewModel.h"
#import "HeadRosterView.h"
#import "WDHTTPManager.h"
#import "ClassModel.h"
#import "HWSubject.h"

@interface RosterViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  数据源
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) CGFloat sectionHeight;

@end

@implementation RosterViewController

static NSString * const reuseIdentifier = @"rosterCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initCollectionView];
    [self loadData];
}

- (void)initView {
    self.title = NSLocalizedString(@"班级花名册", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"退出班级", nil) style:UIBarButtonItemStylePlain target:self action:@selector(exitClassAction)];
}

- (void)initCollectionView {
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.view addSubview:self.collectionView];
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 20;
    CGFloat w = ([UIScreen wd_screenWidth] - 41) / 3;
    self.layout.itemSize = CGSizeMake(w, w);
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[RosterCollectionViewCell class] forCellWithReuseIdentifier:@"RosterCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor hex:0xF5F2F9 alpha:1.0];
    [self.collectionView registerClass:[HeadRosterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadRosterView"];
    self.layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

#pragma mark collectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([UIScreen wd_screenWidth], self.sectionHeight + 90);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RosterCollectionViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:self.dataSource[indexPath.row]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader){
        HeadRosterView *v = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadRosterView" forIndexPath:indexPath];
        [v setValueForDataSource:self.classModel];
        return v;
    }
    return nil;
}

- (void)loadData {
    RosterViewModel *publicModel = [RosterViewModel new];
    [publicModel setBlockWithReturnBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        self.dataSource = returnValue;
        [self.collectionView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [SVProgressHUD dismiss];
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];
    [publicModel fetchPublicRosterWithModel:self.classModel];
    [SVProgressHUD show];
    
    self.sectionHeight = [self.classModel.roleAndSubject sizeOfStringWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake([UIScreen wd_screenWidth] - 20, CGFLOAT_MAX)].height;
}

///  退出班级方法
- (void)exitClassAction {
    MOExitClassViewController *vc = [MOExitClassViewController new];
    if (self.classModel.roleCode.count == 2 || [self.classModel.roleCode containsObject:@"01"]) { // 班主任
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:self.classModel.kmList];
        HWSubject *sub = [HWSubject new];
        sub.subjectCH = NSLocalizedString(@"班主任", nil);
        sub.subjectID = @"jsjs";
        [arrayM insertObject:sub atIndex:0];
        vc.data = arrayM;
    } else {
        vc.data = self.classModel.kmList;
    }
    vc.bjId = self.classModel.id;
    WEAKSELF(self);
    vc.exitSucceed = ^(NSMutableArray<HWSubject *> *data) {
        
        NSMutableString *strM = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", data.count > 0 ?
            [NSString stringWithFormat:@"%@ %@:", NSLocalizedString(@"任课教师", nil), NSLocalizedString(@"科目", nil)] : @""]];
        HWSubject *temp;
        for (HWSubject *item in data) {
            if ([item.subjectID isEqualToString:@"jsjs"]) {
                [strM insertString:[NSString stringWithFormat:@"%@  ", NSLocalizedString(@"班主任", nil)] atIndex:0];
                temp = item;
                continue;
            }
            [strM appendString:[NSString stringWithFormat:@"%@、", item.subjectCH]];
        }
        if (temp) {
            [data removeObject:temp];
        }
        if (data.count > 0) {
            [strM deleteCharactersInRange:NSMakeRange(strM.length - 1, 1)];
        }
        weakSelf.classModel.roleAndSubject = strM;
        weakSelf.classModel.kmList = data;
        [weakSelf.collectionView reloadData];
        weakSelf.exitSucceed(weakSelf.classModel);
        if (strM.length == 0) {
            [weakSelf.navigationController popViewControllerAnimated:true];
        }
    };
    [self.navigationController pushViewController:vc animated:true];
}

@end
