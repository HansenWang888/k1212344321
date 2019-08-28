//
//  MyClassViewController.m
//  Wd_Setting
//
//  Created by cindy on 15/10/16.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "MyClassViewController.h"
#import "MOAddClassViewController.h"
#import "MyClassTableViewCell.h"
#import "RosterViewController.h"
#import "MyClassViewModel.h"
#import "WDHTTPManager.h"
#import "ClassModel.h"

@interface MyClassViewController ()<UITableViewDelegate, UITableViewDataSource>

///  tableView
@property (nonatomic, strong) UITableView *tableView;
///  导航图片
@property (nonatomic, strong) UIImageView *imageView;
///  数据源
@property (nonatomic, strong) NSMutableArray *dataSource;
///  缓存行高
@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;

@end

@implementation MyClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initView];
    [self loadData];
}

- (void)initNavigation {
    
    self.title = NSLocalizedString(@"我的班级", nil);
    UIButton * navRigthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRigthBtn.frame = CGRectMake(0, 0, 100, 44);
    navRigthBtn.backgroundColor = [UIColor clearColor];
    [navRigthBtn setTitle:NSLocalizedString(@"加入班级", nil) forState:UIControlStateNormal];
    navRigthBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    [navRigthBtn addTarget:self action:@selector(clickNavRight:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRigthBtn];
}

- (void)initView {
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:[UIColor hex:0xF5F2F9 alpha:1.0] separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[MyClassTableViewCell class] cellIdentifier:@"MyClassTableViewCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
    }];
    [self.tableView registerClass:[MyClassTableViewCell class] forCellReuseIdentifier:@"MyClassTableViewCell"];
    self.cellHeightCache = [NSMutableDictionary dictionary];
    self.tableView.estimatedRowHeight = 95.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    [self.imageView zk_AlignInner:(ZK_AlignTypeTopLeft) referView:self.view size:(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64)) offset:(CGPointMake(0, 0))];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.view.window.layer renderInContext:ctx];
    UIImage *imgScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = imgScreen;
}


-(void)clickNavRight:(UIButton*)sender {
    MOAddClassViewController *vc = [MOAddClassViewController new];
    vc.myClassData = self.dataSource;
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] doubleValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyClassTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MyClassTableViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:self.dataSource[indexPath.row]];
    self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] = @(CGRectGetMaxY(cell.roleLabel.frame) + 10);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RosterViewController * rosterVc = [[RosterViewController alloc]init];
    ClassModel *clmo = self.dataSource[indexPath.row];
    rosterVc.classModel = clmo;
    WEAKSELF(self);
    rosterVc.exitSucceed = ^(ClassModel *classModel) {
        if (classModel.roleAndSubject.length == 0) {
            [weakSelf.dataSource removeObject:classModel];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    };
    [self.navigationController pushViewController:rosterVc animated:YES];
}

- (void)loadData {
    MyClassViewModel *publicModel = [MyClassViewModel new];
    [publicModel setBlockWithReturnBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        self.dataSource = [NSMutableArray arrayWithArray:returnValue];
        [self.tableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [SVProgressHUD dismiss];
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];
    [publicModel fetchPublicMyClass];
    [SVProgressHUD show];
}

@end
