//
//  IMSearchSubscribeVC.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/7/7.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "IMSearchSubscribeVC.h"
#import "SearchUserViewController.h"
#import "SearchSubscribeCell.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import "SubscribeInfoController.h"
@interface IMSearchSubscribeVC ()<UISearchBarDelegate,UISearchResultsUpdating>
@property (nonatomic, copy) NSArray *sbs;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation IMSearchSubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = IMLocalizedString(@"查找公众号", nil);
    self.navigationItem.hidesBackButton = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchSubscribeCell" bundle:nil] forCellReuseIdentifier:@"subCell"];
    self.searchBar = [UISearchBar new];
        self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.showsScopeBar = YES;
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.searchBar becomeFirstResponder];
    self.searchBar.placeholder = IMLocalizedString(@"搜索公众号获取最新资讯", nil);
    self.tableView.tableFooterView = [UIView new];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [self searchDataWithText:searchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.sbs = nil;
        [self.tableView reloadData];
    }
}
- (void)searchDataWithText:(NSString *)text {
    //公众号
    [[SubscribeModule shareInstance] SearchSubscribe:text Block:^(NSArray<SubscribeEntity *> *sbAry) {
        if (sbAry) {
            _sbs = sbAry;
            [self.tableView reloadData];
        }
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchDataWithText:textField.text];
    [textField endEditing:YES];
    return YES;
}
#pragma mark TABLEVIEW_DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _sbs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //搜索公众号
    SearchSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subCell" forIndexPath:indexPath];
    SubscribeEntity *entity = _sbs[indexPath.row];
    cell.subEntity = entity;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar endEditing:YES];
    SubscribeEntity* sbentity = _sbs[indexPath.row];
    SubscribeInfoController* vc = [[SubscribeInfoController alloc]initWithSBID:sbentity.objID];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
