//
//  mySettingViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/10/21.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "mySettingViewController.h"
#import "WDLoginModule.h"
#import <SDImageCache.h>

@interface mySettingViewController ()<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIImageView *imageView;
///  是否是退出按钮
@property (nonatomic, assign) int didSel;
///  清除缓存label
@property (nonatomic, strong) UILabel *clearCacheLabel;

@end

@implementation mySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.title = NSLocalizedString(@"设置", nil);//STLocalizedString(@"设置", nil);
    self.dataSource = @[
                        @[NSLocalizedString(@"客服电话", nil),
                          NSLocalizedString(@"电子邮箱", nil),
                         /* NSLocalizedString(@"上传日志", nil), */
                          NSLocalizedString(@"清除缓存", nil)],
                        @[NSLocalizedString(@"注销", nil)]
                        ];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    [self.imageView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:(CGSizeMake([UIScreen wd_screenWidth], 64)) offset:CGPointZero];
    
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:[UIColor hex:0xF5F2F9 alpha:1.0] separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[UITableViewCell class] cellIdentifier:@"UITableViewCell"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
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

#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 30 : 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) { return nil; }
    UIView * v = [[UIView alloc]init];
    v.backgroundColor = [UIColor clearColor];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(13, 10, 200, 20)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = NSLocalizedString(@"关于我们", nil);
    [v addSubview:label];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.accessoryType = indexPath.section == 1 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    if (indexPath.section == 0) {
        UILabel * rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(CURRENT_DEVICE_SIZE.width - 170, 2, 160, 40)];
        if (indexPath.section == 0 && indexPath.row == 3) {
            self.clearCacheLabel = rightLabel;
        }
        if (indexPath.row == 0) {
            rightLabel.text = @"400-012-6176";
        }else if (indexPath.row == 1) {
            rightLabel.text = @"Service@wdcloud.cc";
        }/*else if (indexPath.row == 2) {
            rightLabel.text = @"";
        }*/else if (indexPath.row == 2) {
            rightLabel.text = [self getUsedCache];
        }
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:rightLabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.didSel = false;
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"客服电话", nil) message:[NSString stringWithFormat:@"%@400-012-6176", NSLocalizedString(@"是否拨打客服电话", nil)] delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil] show];
        self.didSel = 0;
    }/* else if (indexPath.section == 0 && indexPath.row == 2) {//上传日志
        [self uploadLogAction];
    }*/else if (indexPath.section == 0 && indexPath.row == 2) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"清除缓存", nil) message:NSLocalizedString(@"会清除所有缓存、离线的内容及图片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil] show];
        self.didSel = 1;
    } else if(indexPath.section == 1){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"注销", nil) message:NSLocalizedString(@"是否注销当前帐号", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil] show];
        self.didSel = 2;
    }
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.didSel == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4000126176"]];
        } else if (self.didSel == 1) {
            [self clearCacheAction];
        } else if (self.didSel == 2) {
            [[WDLoginModule shareInstance] LogOut];
            [[NSNotificationCenter defaultCenter]postNotificationName:logoutNotifacation object:nil];
        }
    }
}

- (void)uploadLogAction {

    if ([WDLogManager isWifiStatus]) {
        [self uploadAction];
    } else {
        UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"网络环境", nil) message:NSLocalizedString(@"当前为非Wi-Fi网络，是否继续上传？", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *trueAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"上传", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self uploadAction];
        }];
        UIAlertAction *falseAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alc addAction:trueAc];
        [alc addAction:falseAc];
        [self presentViewController:alc animated:YES completion:nil];
    }
}

- (void)uploadAction {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在上传...", nil)];
    [WDLogManager uploadUserLogFinished:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"上传日志成功", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"上传日志失败", nil)];
            }
        });
    }];
}


- (NSString *)getUsedCache {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
    }
    folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
    return [NSString stringWithFormat:@"%.1f M", folderSize];
}

///  计算单个文件大小
- (float)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

- (void)clearCacheAction {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[SDImageCache sharedImageCache] clearMemory];
    WEAKSELF(self);
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSString *size = [weakSelf getUsedCache];
        weakSelf.clearCacheLabel.text = size;
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"清理完毕", nil)];
        [[WDLoginModule shareInstance] LogOut];
        [[NSNotificationCenter defaultCenter]postNotificationName:logoutNotifacation object:nil];
    }];
}

@end
