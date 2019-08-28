//
//  IMAddContactVC.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/7/7.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "IMAddContactVC.h"
#import "IMSearchTableVC.h"
#import "ModifyGroupMemberViewController.h"
#import "SearchUserViewController.h"
#import "IMSearchSubscribeVC.h"
#import "QRViewController.h"
#import "HyperLinkVC.h"
#import "SubscribeModule.h"
#import "SubscribeInfoController.h"
#import "SubscribeEntity.h"
#import "UIColor+Hex.h"

@interface IMAddContactVC ()<UISearchBarDelegate>
@property (nonatomic, copy) NSArray *lists;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation IMAddContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = IMLocalizedString(@"添加联系人", nil);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contactCell"];
    self.lists = @[
                   @{@"text": IMLocalizedString(@"公众号", nil), @"detailText": IMLocalizedString(@"获取更多资讯和服务", nil)},
                   @{@"text": IMLocalizedString(@"新建会话组", nil),@"detailText":@""},
                   @{@"text": IMLocalizedString(@"扫一扫", nil),@"detailText": IMLocalizedString(@"扫描二维码名片", nil)}];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.placeholder = IMLocalizedString(@"查找好友", nil);
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    self.tableView.rowHeight = 49;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SearchUserViewController *vc = [SearchUserViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactCell"];
    cell.textLabel.text = self.lists[indexPath.row][@"text"];
    cell.detailTextLabel.text = self.lists[indexPath.row][@"detailText"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
//    cell.imageView.image = self.lists[indexPath.row][@"image"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.imageView setTintColor:[UIColor ColorWithHexRGBA:@"#3DA99DFF"]];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
            //搜索公众号、
            vc = [IMSearchSubscribeVC new];
            break;
        case 1:
            //新建会话组
            vc = [[ModifyGroupMemberViewController alloc]init];
            break;
        case 2:
            //扫一扫
            if (1) {
                QRViewController *qr = [[QRViewController alloc] init];
                WEAKSELF(self);
                qr.qrUrlBlock = ^(NSString *url){
                    [weakSelf QRresult:url];
                };
                vc = qr;
            }
            break;
    }
    if (vc == nil) return;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)QRresult:(NSString *)url {
    if ([url hasPrefix:@"http://"]) {
        //如果是http请求就用网页展示
        HyperLinkVC *vc = [[HyperLinkVC alloc] initWithHyperLink:url AndTitle:IMLocalizedString(@"网页内容", nil)];
        [self.navigationController pushViewController:vc  animated:YES];
        return ;
    }
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    NSArray* array = [url componentsSeparatedByString:@"_"];
    if(array.count ==2){
        
        [[SubscribeModule shareInstance]getSubscribeByUUID:array[0] Differno:array[1] Block:^(SubscribeEntity *sbentity) {
            if(sbentity != nil){
                [SVProgressHUD dismiss];
                SubscribeInfoController* vc = [[SubscribeInfoController alloc]initWithSBID:sbentity.objID];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"获取失败", nil)];
            }
        }];
    }
    else{
        [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"获取失败", nil)];
    }
}

@end
