//
//  IMSearchTableVC.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/1.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "IMSearchTableVC.h"
#import "ContactModule.h"
#import "ContactInfo.h"
#import "DDUserModule.h"
#import "ContactDataModel.h"
#import "userAbstractCell.h"
#import "UserInfoViewController.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import "SubscribeListVC.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "SubscribeInfoController.h"

@interface IMSearchTableVC ()
@property (nonatomic, strong) NSArray *contacts;

@end

@implementation IMSearchTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UserAbstractCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SBInfoCell" bundle:nil] forCellReuseIdentifier:@"SBInfoCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isSearchSubscribe) {
        return [self creatSubscribeCellWithIndexPath:indexPath];
    }
    return [self creatUserCellWithIndexPath:indexPath];
}
- (UserAbstractCell *)creatUserCellWithIndexPath:(NSIndexPath *)indexPath {
    ContactUserAbstract *info = self.contacts[indexPath.row];
    UserAbstractCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.userAbstrct = info;
    return cell;
}
- (SBInfoCell *)creatSubscribeCellWithIndexPath:(NSIndexPath *)indexPath {
    
    SBInfoCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SBInfoCell" forIndexPath:indexPath];
    SubscribeEntity* sbattentity = self.contacts[indexPath.row];
    [cell.naleLabel setSBID:sbattentity.objID];
    [cell.avatarImageView setSBID:sbattentity.objID];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearchSubscribe) {
        SubscribeEntity *entity = self.contacts[indexPath.row];
        SubscribeInfoController *infoVC = [[SubscribeInfoController alloc] initWithSBID:entity.objID];
        [self.navigationController pushViewController:infoVC animated:YES];
    } else {
        ContactUserAbstract *info = self.contacts[indexPath.row];
        UserInfoViewController *vc = [UserInfoViewController new];
        vc.isContactVC = YES;
        [vc setUserID:info.uid];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.text.length == 0) {
        return;
    }
    if (self.isSearchSubscribe) {
        [self searchSubcribeWithSeachText:searchController.searchBar.text];
    } else {
        [self searchContactWithSeachText:searchController.searchBar.text];
    }
    [self.tableView reloadData];

}
- (void)searchContactWithSeachText:(NSString *)text {
    NSMutableArray *arrayM = @[].mutableCopy;
    for (ContactInfoEntity *entity in [[ContactModule shareInstance] GetContactUser]) {
        [arrayM addObject:[[ContactUserAbstract alloc] initWithUserEntityAndContactInfoEntity:[[DDUserModule shareInstance] getUserByID:entity.objID] ContactInfoEntity:entity]];
    }
    self.contacts = [arrayM filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"nick CONTAINS '%@'",text]]];
}
- (void)searchSubcribeWithSeachText:(NSString *)text {
    NSMutableArray *arrayM = @[].mutableCopy;
    for (SubscribeEntity *entity in [[SubscribeModule shareInstance] getSubs]) {
        [arrayM addObject:[[SubscribeModule shareInstance] getSubscribeBySBID:entity.objID]];
    }
    self.contacts = [arrayM filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name CONTAINS '%@'",text]]];
}
@end
