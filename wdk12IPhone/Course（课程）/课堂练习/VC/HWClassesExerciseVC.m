//
//  HMClassesExerciseVC.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesExerciseVC.h"
#import "WDHTTPManager.h"
#import "HWClasseExerciseCell.h"
#import "HWClassesList.h"
#import <MJRefresh.h>
#import "HWClassesScanVC.h"
#import "HWCExerciseEncodeManager.h"
@interface HWClassesExerciseVC ()
@property (nonatomic, strong) NSMutableArray *bjList;
@property (assign, nonatomic) NSInteger currentTS;

@end
#define MYTS @"10"
@implementation HWClassesExerciseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"跳过", nil) style:0 target:self action:@selector(rightBtnClick)];
    self.title = NSLocalizedString(@"课堂练习", nil); //@"课堂练习";
    [self.tableView registerNib:[UINib nibWithNibName:@"HWClasseExerciseCell" bundle:nil] forCellReuseIdentifier:@"excerciseCell"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.bjList = @[].mutableCopy;
    self.tableView.rowHeight = 80;
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [UIView new];
    //加载扫描编码
    [HWCExerciseEncodeManager exerciseEncodeShareManager];
}
- (void)loadData {
    self.currentTS = 0;
    [self getDataFinished:^(NSDictionary *response) {
        if (response) {
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            [self.tableView.mj_header endRefreshing];
            self.tableView.mj_footer.hidden = NO;
            [self.bjList removeAllObjects];
            NSArray *list = response[@"data"][@"bjList"];
            for (NSDictionary *dict in list) {
                [self.bjList addObject:[HWClassesList classesListWithDict:dict]];
            }
            self.currentTS = [response[@"data"][@"qsts"] integerValue];
            if (list.count < MYTS.integerValue) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else if (list == 0) {
                self.tableView.mj_footer.hidden = YES;
            }
            [self.tableView reloadData];
        } else {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}
- (void)loadMoreData {
    [self getDataFinished:^(NSDictionary *response) {
        if (response) {
            [self.tableView.mj_footer endRefreshing];
            NSArray *list = response[@"data"][@"bjList"];
            if (list.count > 0) {
                NSMutableArray *indexes = @[].mutableCopy;
                NSInteger index = self.bjList.count;
                for (NSDictionary *dict in list) {
                    [self.bjList addObject:[HWClassesList classesListWithDict:dict]];
                    [indexes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                    index ++;
                }
                [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:0];
                self.currentTS = [response[@"data"][@"qsts"] integerValue];
                if (list.count < MYTS.integerValue) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}
- (void)getDataFinished:(void(^)(NSDictionary*))finished {
    NSString *url = [NSString stringWithFormat:@"%@getKTLXBJList",UNIFIED_USER_KTLX_URL];
    NSDictionary *dict = @{@"xxID":[WDTeacher sharedUser].schoolID,@"jszh":[WDUser sharedUser].loginID,@"qsts":@(self.currentTS),@"myts":MYTS,@"userType":[WDUser sharedUser].userType};
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:dict urlString:url finished:^(NSDictionary *response) {
        if (response) {
            finished(response);
        } else {
            finished(nil);
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"加载失败！", nil)];
        }
    }];
}
- (void)rightBtnClick {
    HWClassesScanVC *vc = [HWClassesScanVC new];
    [vc hideSubmitButton];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bjList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HWClassesList *list = self.bjList[indexPath.row];
    HWClasseExerciseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"excerciseCell" forIndexPath:indexPath];
    [cell showDataWithClasseList:list];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HWClassesList *list = self.bjList[indexPath.row];
    HWClassesScanVC *vc = [HWClassesScanVC classesScanWithBjID:list.bjID];
    [self presentViewController:vc animated:YES completion:nil];
}
@end
