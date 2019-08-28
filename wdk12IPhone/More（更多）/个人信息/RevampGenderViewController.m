//
//  RevampGender.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/18.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "RevampGenderViewController.h"
#import "WDHTTPManager.h"

@interface RevampGenderViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RevampGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
}

- (void)initTableView {
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:nil separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[UITableViewCell class] cellIdentifier:@"UITableViewCell"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    
    UIView *footView = [UIView new];
    footView.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth], 80);
    UIButton *footButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"确定", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x5DA28F alpha:1.0]];
    [footView addSubview:footButton];
    footButton.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth] - 40, 50);
    footButton.center = footView.center;
    footButton.layer.cornerRadius = 5;
    footButton.layer.masksToBounds = true;
    self.tableView.tableFooterView = footView;
    [footButton addTarget:self action:@selector(clickCommit) forControlEvents:UIControlEventTouchUpInside];
    self.title = NSLocalizedString(@"性别", nil);
}

- (void)clickCommit {
    
    WDUser * user =  [WDUser sharedUser];
    [SVProgressHUD show];
    
    NSDictionary * getDic = @{@"zdmc"   :@"xb",
                              @"zdz"    :self.genderType,
                              @"yhlb"   :user.userType,
                              @"loginID":user.loginID};
    
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:getDic urlString:[NSString stringWithFormat:@"%@/gd!updateGRXX.action",EDU_BASE_URL] finished:^(NSDictionary *dic) {
        
        if ([[dic objectForKey:@"isSuccess"] isEqualToString:@"true"]) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"修改成功", nil)];
            //修改数据源
            user.sex = [self.genderType intValue];
            if (self.modifySex) {
                self.modifySex();
            }
            [self.navigationController popViewControllerAnimated:true];
        } else {
             [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"修改失败", nil)];
        }
    }];
    
}


#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = NSLocalizedString((indexPath.row == 0 ? @"男" : @"女"), nil);
    cell.accessoryType = indexPath.row == 0 ? ([self.genderType isEqualToString:@"1"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone) :
                                              ([self.genderType isEqualToString:@"2"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.genderType = indexPath.row == 0 ? @"1" : @"2";
    [self.tableView reloadData];
}

@end
