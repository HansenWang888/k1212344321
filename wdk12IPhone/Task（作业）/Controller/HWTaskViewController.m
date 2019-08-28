//
//  HWTaskViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskViewController.h"
#import "CenterTitleCollectionViewCell.h"
#import "HWCreatTaskViewController.h"
#import "HWTaskCheckViewController.h"
#import "HWTaskListTableViewCell.h"
#import "HWTaskListPreviewCell.h"
#import "SubjectListRequest.h"
#import "HWTaskListRequest.h"
#import "HWTaskModel.h"
#import "HWSubject.h"
#import <MJRefresh.h>

@interface HWTaskViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UITableView *tableView;
///  全部按钮
@property (nonatomic, strong) UIButton *allButton;
///  标题文字
@property (nonatomic, copy) NSString *titleText;
///  collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
///  布局类
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  遮罩按钮
@property (nonatomic, strong) UIButton *shadeButton;
///  科目数据源
@property (nonatomic, copy) NSArray *subjectData;
///  cellectionview 高
@property (nonatomic, assign) CGFloat h;
///  临时数据
@property (nonatomic, strong) HWSubject *tempData;
///  临时选中的index
@property (nonatomic, strong) NSIndexPath *tempIndex;
///  作业列表
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;
///  请求类
@property (nonatomic, strong) SubjectListRequest *request;
///  提示label
@property (nonatomic, strong) UILabel *promptLabel;
@end

@implementation HWTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initTableView];
    [self initView];
    [self loadAllSubject];
}

- (void)initNav {
    NSString *titleStr = [NSString stringWithFormat:@"%@ \U0000e613", NSLocalizedString(@"全部", nil)];
    self.allButton = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:18] title:titleStr titleColor:[UIColor whiteColor] backgroundColor:nil];
    NSString *titleSel = [NSString stringWithFormat:@"%@ \U0000e65e", NSLocalizedString(@"全部", nil)];
    [self.allButton setTitle:titleSel forState:(UIControlStateSelected)];
    self.navigationItem.titleView = self.allButton;
    self.allButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.allButton.bounds = CGRectMake(0, 0, 200, 50);
    [self.allButton addTarget:self action:@selector(showAllSubjectWith:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:18] title:@"\U0000e625" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(createTaskAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
}

///  创建作业方法
- (void)createTaskAction {
    if (self.allButton.isSelected) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请先退出选择科目模式", nil)];
        return ;
    }
    HWCreatTaskViewController *vc = [HWCreatTaskViewController new];
    [vc setHidesBottomBarWhenPushed:true];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)initView {
    
    self.promptLabel = [UILabel labelBackgroundColor:nil textColor:nil font:[UIFont systemFontOfSize:15] alpha:0];
    [self.view addSubview:self.promptLabel];
    self.promptLabel.text = NSLocalizedString(@"没有更多内容了", nil);
    self.promptLabel.alpha = 0;
    [self.promptLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.view size:CGSizeZero offset:CGPointZero];
    
    self.shadeButton = [UIButton new];
    self.shadeButton.backgroundColor = [UIColor hex:0x000000 alpha:0.7];
    [self.view addSubview:self.shadeButton];
    self.shadeButton.alpha = 0.0;
    [self.shadeButton zk_Fill:self.view insets:UIEdgeInsetsZero];
    [self.shadeButton addTarget:self action:@selector(closeAllSubjectAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alpha = 0;
    [self.view addSubview:self.collectionView];
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.sectionInset = UIEdgeInsetsMake(64+20, 20, 20, 20);
    CGFloat w = ([UIScreen wd_screenWidth] - 40) / 3;
    self.layout.itemSize = CGSizeMake(w, w);
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellAccessoryNone;
    [self.tableView registerClass:[HWTaskListTableViewCell class] forCellReuseIdentifier:@"HWTaskListTableViewCell"];
    [self.tableView registerClass:[HWTaskListPreviewCell class] forCellReuseIdentifier:@"HWTaskListPreviewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 62;
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.cellHeightCache = [NSMutableDictionary dictionary];
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadDataWithKMid:self.subjectID];
    }];
    header.stateLabel.font = [UIFont systemFontOfSize:12];
    self.tableView.mj_header = header;
    
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadNextPageData];
    }];
    footer.automaticallyHidden = NO;
    footer.automaticallyRefresh = YES;
    footer.automaticallyChangeAlpha = YES;
    footer.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    footer.stateLabel.font = [UIFont systemFontOfSize:12];
    self.tableView.mj_footer = footer;
}

- (void)loadDataWithKMid:(NSString *)kmid {
    if (!self.request) {
        self.request = [SubjectListRequest new];
    }
    self.request.kmID = kmid;
    [SVProgressHUD showWithStatus:@""];
    [self.request fetchFirstPageModels:^(NSArray *data) {
        [SVProgressHUD dismiss];
        [self.tableView.mj_header endRefreshing];
        self.dataSource = data.mutableCopy;
        self.promptLabel.alpha = self.dataSource.count == 0 ? 1.0 : 0.0;
        [self.tableView reloadData];
    }];
}

- (void)loadNextPageData {
    [self.request fetchNextPageModels:^(NSArray *data) {
        [self.tableView.mj_footer endRefreshing];
        if (data.count > 0) {
            [self.dataSource addObjectsFromArray:data];
            self.promptLabel.alpha = self.dataSource.count == 0 ? 1.0 : 0.0;
            [self.tableView reloadData];
        }
    }];
}

- (void)closeAllSubjectAction {
    [self showAllSubjectWith:self.allButton];
}

#pragma mark - collectionView delegate and dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.subjectData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:self.subjectData[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.tempData.isSel = false;
    HWSubject *sub = self.subjectData[indexPath.row];
    sub.isSel = true;
    if (self.tempIndex) {
        [self.collectionView reloadItemsAtIndexPaths:@[self.tempIndex]];
    }
    self.tempData = sub;
    self.tempIndex = indexPath;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    self.subjectID = sub.subjectID;
    self.titleText = sub.subjectCH;
    [self showAllSubjectWith:self.allButton];
    [self.dataSource removeAllObjects];
    self.request.yxqs = 0;
    self.request.zyqs = 0;
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 数据源及代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] doubleValue];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.dataSource || self.dataSource.count == 0) { return [UITableViewCell new]; }
    HWTaskModel *data = self.dataSource[indexPath.row];
    if ([data.zylx isEqualToString:@""]) {
        HWTaskListPreviewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWTaskListPreviewCell" forIndexPath:indexPath];
        [cell setValueForDataSource:self.dataSource[indexPath.row]];
        self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] = @(CGRectGetMaxY(cell.bottomView.frame));
        return cell;
    } else {
        HWTaskListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWTaskListTableViewCell" forIndexPath:indexPath];
        [cell setValueForDataSource:data];
        self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] = @(CGRectGetMaxY(cell.bottomView.frame));
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count == 0) { return ; }
    HWTaskCheckViewController *vc = [HWTaskCheckViewController new];
    vc.taskModel = self.dataSource[indexPath.row];
    [vc setHidesBottomBarWhenPushed:true];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)loadAllSubject {
    [SVProgressHUD show];
    WEAKSELF(self);
    [HWTaskListRequest fetchPublicTeacherSubject:^(NSArray *data) {
        [SVProgressHUD dismiss];
        weakSelf.subjectData = data;
        if (weakSelf.subjectData.count > 0) {
            HWSubject *item = [weakSelf.subjectData firstObject];
            weakSelf.tempData = item;
            weakSelf.tempIndex = [NSIndexPath indexPathWithIndex:0];
            item.isSel = true;
            weakSelf.titleText = item.subjectCH;
            CGFloat w = ([UIScreen wd_screenWidth] - 40) / 3;
            CGFloat h = (weakSelf.subjectData.count / 3 + ((weakSelf.subjectData.count % 3 > 0) ? 1 : 0)) * w + 40 + 64;
            if (h > w * 3 + 64 + 40) {
                h = w * 3 + 64 + 40;
            }

            weakSelf.h = h;
            weakSelf.collectionView.frame = CGRectMake(0, -h, [UIScreen wd_screenWidth], h);
            [weakSelf.collectionView reloadData];
            weakSelf.subjectID = [weakSelf.subjectData.firstObject subjectID];
            [weakSelf.tableView.mj_header beginRefreshing];
        }
    }];
}

///  显示全部科目方法
- (void)showAllSubjectWith:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [sender setTitle:[NSString stringWithFormat:@"%@ %@", self.titleText, !sender.isSelected ? @"\U0000e65e" : @"\U0000e613"] forState:UIControlStateNormal];
    [sender setTitle:[NSString stringWithFormat:@"%@ %@", self.titleText, !sender.isSelected ? @"\U0000e65e" : @"\U0000e613"] forState:UIControlStateSelected];
    self.collectionView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.collectionView.y = !sender.selected ? -self.h : 0;
        self.shadeButton.alpha = sender.selected ? 1.0 : 0.0;
        self.tabBarController.tabBar.alpha = sender.selected ? 0 : 1.0;
    }];
}

@end
