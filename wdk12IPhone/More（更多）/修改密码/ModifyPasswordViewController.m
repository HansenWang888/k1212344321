//
//  ModifyPasswordViewController.m
//  Wd_Setting
//
//  Created by cindy on 15/10/16.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "ModifyPasswordTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "WDHTTPManager.h"

@interface ModifyPasswordViewController ()<UITextFieldDelegate> {
    NSArray * holders;
    UITextField * oldPsd1;
    UITextField * xinPsd1;
    UITextField * xinPsd2;
}

@property (strong, nonatomic) IBOutlet UIView *myHeadView;
@property (strong, nonatomic) IBOutlet UIView *myFootView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *myOkBtn;
@property (weak, nonatomic) IBOutlet UILabel *myNickname;
@property (weak, nonatomic) IBOutlet UILabel *myAccount;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    self.title = NSLocalizedString(@"修改密码", nil);
    [self.myTableView registerClass:[ModifyPasswordTableViewCell class] forCellReuseIdentifier:@"ModifyPasswordTableViewCell"];
    self.myTableView.tableHeaderView = self.myHeadView;
    self.myTableView.tableFooterView = self.myFootView;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myOkBtn.layer.cornerRadius = 4;
    holders = @[@"输入当前密码",@"输入新密码",@"再次输入新的密码"];
    WDUser * user =  [WDUser sharedUser];
    //头像
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
    //昵称
    self.myNickname.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"昵称", nil), user.nickName];
    //帐号
    self.myAccount.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"帐号", nil) ,user.loginID];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    [self.imageView zk_AlignInner:(ZK_AlignTypeTopLeft) referView:self.view size:(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64)) offset:(CGPointMake(0, 0))];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = false;
}

- (IBAction)clickCommit:(id)sender {
    
    if ([oldPsd1.text isEqualToString:@""] || [xinPsd1.text isEqualToString:@""] || [xinPsd2.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"密码不能为空", nil)];
        return;
    }
    if (![xinPsd1.text isEqualToString:xinPsd2.text]) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"两次输入不一致", nil)];
        return;
    }
    NSDictionary * postDic =  @{@"loginid":[WDUser sharedUser].loginID,
                                @"oldpassword":oldPsd1.text,
                                @"newpassword":xinPsd1.text};
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]postHTTPSWithParameterDict:postDic urlString:[NSString stringWithFormat:@"%@/ptyhzx-uic/rest/v1/users/password/updateValidateByLoginID",UNIFIED_USER_BASE_URL] contentType:@"application/json" finished:^(NSDictionary *dict) {
        
        if ([[dict objectForKey:@"result"] isEqualToString:@"1"]) {
            //成功
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"密码修改成功，下次登录请使用新密码", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //失败
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"密码修改失败", nil)];
        }
    }];
}

#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ModifyPasswordTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ModifyPasswordTableViewCell" forIndexPath:indexPath];
    cell.textField.placeholder = NSLocalizedString(holders[indexPath.row], nil);
    cell.textField.delegate = self;
    
    if (indexPath.row == 0) {
        oldPsd1 = cell.textField;
    }else if (indexPath.row == 1){
        xinPsd1 = cell.textField;
    }else if (indexPath.row == 2){
        xinPsd2 = cell.textField;
    }
    return cell;
}

#pragma mark textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
