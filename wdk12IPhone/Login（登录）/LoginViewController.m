//
//  LoginViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "LoginViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "MainViewController.h"
#import "WDLoginModule.h"
#import "UIImage+FullScreen.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (nonatomic) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountText;
///  密码
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (assign, nonatomic, getter=isTeacher) BOOL isTeacher;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantMiddle;
@property (nonatomic,copy) NSString *usertype;
@property (assign, nonatomic) BOOL isEndEdting;
@property (assign, nonatomic) CGFloat shiftConstant;//要移动的数字
@property (assign, nonatomic) CGFloat loginBtnY;
@property (assign, nonatomic) BOOL isDidShow;

@end

@implementation LoginViewController {
    
    CGFloat _btnbottom;
    CGFloat _cs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *versionLabel = [UILabel new];
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textColor = [UIColor whiteColor];
#if DEBUG
//    versionLabel.text = VERSION_DESCRIPTION;
    versionLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"版本号", nil),[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    //查看日志
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"打开日志列表" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(logBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.bottom.offset(-8);
        
    }];
    
#else
    versionLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"版本号", nil),[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
#endif
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-8);
        make.centerX.offset(0);
    }];
    self.logoImageView.image = [UIImage imageNamed:@"wd_logo_white"];
    self.leftBtn.layer.cornerRadius = 6;
    self.leftBtn.layer.masksToBounds = YES;
    self.rightBtn.layer.cornerRadius = 6;
    self.rightBtn.layer.masksToBounds = YES;
    self.iconImage.layer.cornerRadius = 60;
    self.leftBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 6;
    self.loginBtn.layer.masksToBounds = YES;
    self.leftBtn.backgroundColor = [UIColor orangeColor];
    [self.loginBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateDisabled];
    
    [self.loginBtn setBackgroundImage:[UIImage pureColorImage:[UIColor grayColor] ForSize:CGSizeMake(4, 4)] forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundImage:[UIImage pureColorImage:THEME_COLOR ForSize:CGSizeMake(4, 4)] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage pureColorImage:[UIColor colorWithRed:91/255.0 green:168/255.0 blue:139/255.0 alpha:1.0] ForSize:CGSizeMake(4, 4)] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradShow:) name:UIKeyboardWillShowNotification object:nil];
    NSString* account,*password,*usertype,*iconstr;
    [[WDLoginModule shareInstance] GetLatestLogin:&account Password:&password UserType:&usertype iconStr:&iconstr];
    if (usertype == nil) {
        usertype = @"03";
    }
    self.usertype = usertype;
    if ([self.usertype isEqualToString:@"03"]) {
        self.leftBtn.backgroundColor = [UIColor orangeColor];
        self.rightBtn.backgroundColor = [UIColor clearColor];
    } else {
        self.leftBtn.backgroundColor = [UIColor clearColor];
        self.rightBtn.backgroundColor = [UIColor orangeColor];
    }
    self.accountText.text = account;
    self.passwordText.text = password;
    _cs = _constantMiddle.constant;    if (self.accountText.text.length > 0 && self.passwordText.text.length > 0) {
        self.loginBtn.enabled = YES;
    }
    [self rightBtnClick];
    self.passwordText.delegate = self;
}
- (void)logBtnClick {
    [WDLogManager openLogFileWithVC:self];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL autologin = [[user objectForKey:AUTO_LOGIN]boolValue];
    if (autologin) {
        [self loginBtnClick];
    }
}

//键盘隐藏
- (void)keyboradHide:(NSNotification *)info {
    
    CGSize kbSize = [[info.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"%f",kbSize.height);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        _constantMiddle.constant = _cs;
    }];
    [self.view layoutIfNeeded];
}
- (void)keyboradShow:(NSNotification *)info {
    
    CGSize kbSize = [[info.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.shiftConstant = CGRectGetMaxY(self.loginBtn.frame) - (CURRENT_DEVICE_SIZE.height - kbSize.height - 10);
        self.constantMiddle.constant += -self.shiftConstant  ;
        [self.view layoutIfNeeded];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDidShow = NO;
    });
}
- (IBAction)startEdting:(UITextField *)sender {
    if (!self.isEndEdting) {
        self.loginBtnY = CGRectGetMaxY(self.loginBtn.frame);
        self.isEndEdting = YES;
    }
}
- (IBAction)editingTextFildChange {
    if (self.accountText.text.length > 0 && self.passwordText.text.length > 0) {
        self.loginBtn.enabled = YES;
    }
    if (self.accountText.text.length == 0 || self.passwordText.text.length == 0) {
        self.loginBtn.enabled = NO;
    }
}

//老师
- (IBAction)rightBtnClick {
    
    self.leftBtn.backgroundColor = [UIColor clearColor];
    self.rightBtn.backgroundColor = [UIColor orangeColor];
    self.usertype = @"01";
}
//登录
- (IBAction)loginBtnClick {
    [self.view endEditing:YES];
    self.loginBtn.transform = CGAffineTransformIdentity;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在登录", nil) maskType:SVProgressHUDMaskTypeBlack];
    
    if (Location) {
        [[WDLoginModule shareInstance] firstStepLoginAccount:self.accountText.text Password:self.passwordText.text UserType:self.usertype Success:^{
            [[NSNotificationCenter  defaultCenter]postNotificationName:loginNotifacation object:nil];
            [[WDLogManager shareManager] setUserID:[WDUser sharedUser].loginID];

        } Failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error.domain]];
            }else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"登录失败", nil)];
            }
        }];
    }else {
        [[WDLoginModule shareInstance] Login:self.accountText.text Password:self.passwordText.text UserType:self.usertype Success:^{
            [[NSNotificationCenter  defaultCenter]postNotificationName:loginNotifacation object:nil];
            [[WDLogManager shareManager] setUserID:[WDUser sharedUser].loginID];
        } Failure:^(NSError * error) {
            [SVProgressHUD dismiss];
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error.domain]];
            }else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"登录失败", nil)];
            }
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.passwordText endEditing:true];
    return true;
}

@end
