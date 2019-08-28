//
//  RevampInfoViewController.m
//  Wd_Setting
//
//  Created by cindy on 15/10/15.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "RevampInfoViewController.h"
#import "WDHTTPManager.h"

@interface RevampInfoViewController ()

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *trueButton;

@end

@implementation RevampInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor hex:0xF9F5FC alpha:1.0];
    self.textField = [UITextField new];
    self.trueButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"确定", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x5DA28F alpha:1.0]];
    [self.trueButton addTarget:self action:@selector(clickOkAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.trueButton];
    self.trueButton.layer.cornerRadius = 5;
    self.trueButton.layer.masksToBounds = true;
    self.textField.backgroundColor = [UIColor whiteColor];
    [self.textField zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake([UIScreen wd_screenWidth], 50) offset:CGPointMake(0, 64)];
    [self.trueButton zk_AlignVertical:ZK_AlignTypeBottomCenter referView:self.textField size:CGSizeMake([UIScreen wd_screenWidth] - 40, 45) offset:CGPointMake(0, 20)];
    [self.textField becomeFirstResponder];
    self.title = self.justTitle;
    [self initTextFieldText];
    self.textField.adjustsFontSizeToFitWidth = true;
}

- (void)initTextFieldText {
    WDUser *user = [WDUser sharedUser];
    if ([self.title isEqualToString:NSLocalizedString(@"昵称", nil)]) {
        self.textField.text = user.nickName;
        self.textField.placeholder = NSLocalizedString(@"请输入2-20个字母以内,或汉字开头", nil);
    } else if ([self.title isEqualToString:NSLocalizedString(@"用户名", nil)]){
        self.textField.text = user.yhm;
    }else if ([self.title isEqualToString:NSLocalizedString(@"个性签名", nil)]){
        self.textField.text = user.PS;
    } else if ([self.title isEqualToString:NSLocalizedString(@"手机号", nil)]){
        self.textField.text = [NSString stringWithFormat:@"%@", user.telephone];
    } else if ([self.title isEqualToString:NSLocalizedString(@"邮箱", nil)]){
        self.textField.text = user.email;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField endEditing:true];
}

//点击确定
- (void)clickOkAction {
    
    NSString * zdmcStr;
    if ([self.title isEqualToString:NSLocalizedString(@"昵称", nil)]) {
        zdmcStr = @"nc";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入昵称", nil)];
            return;
        }
    }else if ([self.title isEqualToString:NSLocalizedString(@"用户名", nil)]){
        zdmcStr = @"yhm";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入用户名", nil)];
            return;
        }
    }else if ([self.title isEqualToString:NSLocalizedString(@"个性签名", nil)]){
        zdmcStr = @"gxqm";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入签名", nil)];
            return;
        }
    }else if ([self.title isEqualToString:NSLocalizedString(@"性别", nil)]){
        zdmcStr = @"xb";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入性别", nil)];
            return;
        }
    }else if ([self.title isEqualToString:NSLocalizedString(@"手机号", nil)]){
        zdmcStr = @"yddh";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入手机号码", nil)];
            return;
        }
    }else if ([self.title isEqualToString:NSLocalizedString(@"邮箱", nil)]){
        zdmcStr = @"dzyx";
        if (!self.textField.text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入邮箱", nil)];
            return;
        }
    }
    WDUser * user =  [WDUser sharedUser];
    [SVProgressHUD show];
    
    NSDictionary *parmeter = @{@"zdmc":zdmcStr,
                               @"zdz":!self.textField.text.length?@"":self.textField.text,
                               @"yhlb":user.userType,
                               @"loginID":user.loginID};
    NSString *urlString = [NSString stringWithFormat:@"%@/gd!updateGRXX.action",EDU_BASE_URL];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:parmeter urlString:urlString finished:^(NSDictionary *dic) {
        if ([[dic objectForKey:@"isSuccess"] isEqualToString:@"true"]) {
            //成功
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"修改成功", nil)];
            //修改数据源
            if ([self.title isEqualToString:NSLocalizedString(@"昵称", nil)]) {
                user.nickName = self.textField.text;
            } else if ([self.title isEqualToString:NSLocalizedString(@"用户名", nil)]){
                user.yhm = self.textField.text;
                
            }else if ([self.title isEqualToString:NSLocalizedString(@"个性签名", nil)]){
                user.PS = self.textField.text;
                
            } else if ([self.title isEqualToString:NSLocalizedString(@"手机号", nil)]){
                user.telephone = self.textField.text;
                
            } else if ([self.title isEqualToString:NSLocalizedString(@"邮箱", nil)]){
                user.email = self.textField.text;
            }
            [self.navigationController popViewControllerAnimated:YES];
            if (self.modifyInfo) {
                self.modifyInfo();
            }
        }else{
            //失败
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"修改失败", nil)];
            
        }
    }];
    
}


@end
