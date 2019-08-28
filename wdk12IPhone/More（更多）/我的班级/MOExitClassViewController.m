//
//  MOExitClassViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MOExitClassViewController.h"
#import "CenterTitleCollectionViewCell.h"
#import "RosterViewModel.h"
#import "HWSubject.h"

@interface MOExitClassViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation MOExitClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initView];
}

- (void)initNav {
    self.title = NSLocalizedString(@"退出班级", nil);//@"退出班级";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", nil) style:UIBarButtonItemStylePlain target:self action:@selector(exitClassAction)];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 10;
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.layout.itemSize = CGSizeMake(([UIScreen wd_screenWidth] - 50) / 4, 40);
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    HWSubject *sub = self.data[indexPath.row];
    sub.index = indexPath;
    [cell setValueForDataSource:sub];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HWSubject *sub = self.data[indexPath.row];
    sub.isSel = !sub.isSel;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

///  退出班级方法
- (void)exitClassAction {
    
    NSString *jsjs = @"02";
    NSMutableString *kmM = [NSMutableString string];
    NSMutableArray *del = [NSMutableArray array];
    
    for (HWSubject *item in self.data) {
        if (item.isSel) {
            if ([item.subjectID isEqualToString:@"jsjs"]) {
                jsjs = @"01";
                [del addObject:item];
                continue;
            }
            [del addObject:item];
            [kmM appendString:[NSString stringWithFormat:@"%@,", item.subjectID]];
        }
    }
    
    if (kmM.length == 0 && ![jsjs isEqualToString:@"01"]) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"请选择科目", nil)];
        return;
    }
    
    if ([jsjs isEqualToString:@"01"] && kmM.length > 0) { // 既要退出班主任也要退出任课老师
        WEAKSELF(self);
        [RosterViewModel exitClassActionJsjs:@"01" bjId:self.bjId km:kmM handler:^(BOOL isSuccess) {
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"班主任退出成功", nil)];
                NSMutableArray *arrayM = [NSMutableArray array];
                for (NSMutableDictionary *item in arrayM) {
                    if (![item[@"bjID"] isEqualToString:weakSelf.bjId]) {
                        [arrayM addObject:item];
                    }
                }
                [WDTeacher sharedUser].masterList = arrayM;
                [RosterViewModel exitClassActionJsjs:@"02" bjId:self.bjId km:kmM handler:^(BOOL isSuccess) {
                    if (isSuccess) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"退出成功", nil)];
                        
                        [WDTeacher sharedUser].teacherList = [NSArray mutableArrayWith:[WDTeacher sharedUser].teacherList.mutableCopy];
                            
                            NSArray *kmList = [kmM componentsSeparatedByString:@","];
                            for (NSString *kmStr in kmList) { // 遍历需要退出的科目
                                for (NSMutableDictionary *item in [WDTeacher sharedUser].teacherList) { // 遍历老师的班级列表
                                    if ([kmStr isEqualToString:item[@"km"]]) {
                                        NSMutableArray *arrayM = [NSMutableArray array];
                                        for (NSDictionary *bjItem in item[@"bjList"]) {
                                            if (![bjItem[@"bjID"] isEqualToString:weakSelf.bjId]) {
                                                [arrayM addObject:bjItem];
                                            }
                                        }
                                        item[@"bjList"] = arrayM;
                                    }
                                }
                            }
                        
                        [weakSelf.data removeObjectsInArray:del];
                        NSMutableArray *delM = [NSMutableArray array];
                        for (HWSubject *item in del) {
                            [delM addObject:item.index];
                        }
                        [weakSelf.collectionView deleteItemsAtIndexPaths:delM];
                        weakSelf.exitSucceed(weakSelf.data);
                        [weakSelf.navigationController popViewControllerAnimated:true];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"退出失败，请稍候重试", nil)];
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"退出失败，请稍候重试", nil)];
            }
        }];
    } else {
        WEAKSELF(self);
        [RosterViewModel exitClassActionJsjs:jsjs bjId:self.bjId km:kmM handler:^(BOOL isSuccess) {
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"退出成功", nil)];
                if ([jsjs isEqualToString:@"01"]) {
                    NSMutableArray *arrayM = [NSMutableArray array];
                    for (NSMutableDictionary *item in arrayM) {
                        if (![item[@"bjID"] isEqualToString:weakSelf.bjId]) {
                            [arrayM addObject:item];
                        }
                    }
                    [WDTeacher sharedUser].masterList = arrayM;
                } else {
                    [WDTeacher sharedUser].teacherList = [NSArray mutableArrayWith:[WDTeacher sharedUser].teacherList.mutableCopy];
                    NSArray *kmList = [kmM componentsSeparatedByString:@","];
                    for (NSString *kmStr in kmList) { // 遍历需要退出的科目
                        for (NSMutableDictionary *item in [WDTeacher sharedUser].teacherList) { // 遍历老师的班级列表
                            if ([kmStr isEqualToString:item[@"km"]]) {
                                NSMutableArray *arrayM = [NSMutableArray array];
                                for (NSDictionary *bjItem in item[@"bjList"]) {
                                    if (![bjItem[@"bjID"] isEqualToString:weakSelf.bjId]) {
                                        [arrayM addObject:bjItem];
                                    }
                                }
                                item[@"bjList"] = arrayM;
                            }
                        }
                    }
                }
                
                [weakSelf.data removeObjectsInArray:del];
                NSMutableArray *delM = [NSMutableArray array];
                for (HWSubject *item in del) {
                    [delM addObject:item.index];
                }
                [weakSelf.collectionView deleteItemsAtIndexPaths:delM];
                weakSelf.exitSucceed(weakSelf.data);
                [weakSelf.navigationController popViewControllerAnimated:true];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"退出失败，请稍候重试", nil)];
            }
        }];
    }
}

@end
