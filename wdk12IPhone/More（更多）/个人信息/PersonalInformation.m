//
//  PersonalInformation.m
//  Wd_Setting
//
//  Created by cindy on 15/10/15.
//  Copyright © 2015年 wd. All rights reserved.
//

#import "PersonalInformation.h"
#import "RevampInfoViewController.h"
#import "RevampGenderViewController.h"
#import "WDHTTPManager.h"
#import <AVFoundation/AVFoundation.h>
#import "PersonalInfoTableViewCell.h"
#import "PersonIconTableViewCell.h"

@interface PersonalInformation ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UITableView *tableView;
///  背景截图
@property (nonatomic, strong) UIImageView *imageView;
///  拍照类
@property (nonatomic, strong) UIImagePickerController *imagePicker;
///  数据源
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation PersonalInformation

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initView];
}

- (void)initView {
    self.title = NSLocalizedString(@"个人信息", nil);
    self.dataSource = @[
                        @[
                            NSLocalizedString(@"修改头像", nil),
                            NSLocalizedString(@"昵称", nil),
                            NSLocalizedString(@"用户名", nil),
                            NSLocalizedString(@"个性签名", nil),
                            NSLocalizedString(@"帐号", nil)
                            ],
                        @[
                            NSLocalizedString(@"姓名", nil),
                            NSLocalizedString(@"性别", nil)
                            ],
                        @[
                            NSLocalizedString(@"手机", nil),
                            NSLocalizedString(@"邮箱", nil)
                            ]
                        ];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    self.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
}

- (void)initTableView {
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:[UIColor hex:0xF5F2F9 alpha:1.0] separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[PersonalInfoTableViewCell class] cellIdentifier:@"PersonalInfoTableViewCell"];
    [self.tableView registerClass:[PersonIconTableViewCell class] forCellReuseIdentifier:@"PersonIconTableViewCell"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [UIView new];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row == 0 ? 100 : 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen wd_screenWidth], 20)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:15];
    if (section == 1 || section == 2) {
        label.text = [NSString stringWithFormat:@"    %@", NSLocalizedString((section == 1 ? @"身份信息" : @"联系方式"), @"")];
    }
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WDUser *user = [WDUser sharedUser];
    if (indexPath.section == 0 && indexPath.row == 0) { // 头像
        PersonIconTableViewCell *iconCell = [self.tableView dequeueReusableCellWithIdentifier:@"PersonIconTableViewCell" forIndexPath:indexPath];
        iconCell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
        [iconCell setValueForDataSource:user.avatar];
        return iconCell;
    }
    PersonalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalInfoTableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 1) { // 昵称
        [cell setValueForDataSource:user.nickName];
    } else if (indexPath.section == 0 && indexPath.row == 2) { // 用户名
        [cell setValueForDataSource:user.yhm];
    }else if (indexPath.section == 0 && indexPath.row == 3) { // 个性签名
        [cell setValueForDataSource:user.PS];
    } else if (indexPath.section == 0 && indexPath.row == 4) { // 注册号
        [cell setValueForDataSource:user.loginID];
    } else if (indexPath.section == 1 && indexPath.row == 0) { // 姓名
        [cell setValueForDataSource:user.userName];
    } else if (indexPath.section == 1 && indexPath.row == 1) { // 性别
        [cell setValueForDataSource:user.sex == 1 ? NSLocalizedString(@"男", nil) : NSLocalizedString(@"女", nil)];
    } else if (indexPath.section == 2 && indexPath.row == 0) { // 手机
        [cell setValueForDataSource:[NSString stringWithFormat:@"%@", user.telephone]];
    } else if (indexPath.section == 2 && indexPath.row == 1) { // 邮箱
        [cell setValueForDataSource: user.email];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row == 4)) { //这是注册号
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"帐号不能修改", @"")];
        return ;
    } else if (indexPath.section == 0 && indexPath.row == 0){ // 修改头像
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"选择", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"照片库", nil), NSLocalizedString(@"拍照", nil), nil];
        actionSheet.actionSheetStyle = 1;
        [actionSheet showInView:self.view];
        return;
    } else if (indexPath.section == 1 && indexPath.row == 0){ //姓名不能修改
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"姓名不能修改", nil)];
        return;
    } else if (indexPath.section == 1 && indexPath.row == 1){ //修改性别
        RevampGenderViewController * genderVc = [[RevampGenderViewController alloc]init];
        genderVc.genderType = [NSString stringWithFormat:@"%tu", [WDUser sharedUser].sex];
        [self.navigationController pushViewController:genderVc animated:YES];
        genderVc.modifySex = ^ {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        };
        return;
    }
    
    RevampInfoViewController *revampVc = [[RevampInfoViewController alloc]init];
    revampVc.justTitle = self.dataSource[indexPath.section][indexPath.row];
    revampVc.modifyInfo = ^ {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.navigationController pushViewController:revampVc animated:YES];
}

#pragma mark requestInternet
-(void)updateHeadImage:(UIImage*)headImage {
    //上传图片
    [[WDHTTPManager sharedHTTPManeger] uploadWithPicture:@[headImage] finished:^(NSDictionary * dic) {
        if ([[dic objectForKey:@"successFlg"]boolValue] == YES) {
            //成功
            [self requestSettingHeadImage:[dic objectForKey:@"msgObj"][0]];
        }
    }];
}

-(void)requestSettingHeadImage:(NSDictionary*)headImageInfo {
    
    WDUser * user =  [WDUser sharedUser];
    NSDictionary * requestDic = @{@"zdmc":@"tx",
                                  @"zdz":[self DataTOjsonString:headImageInfo],
                                  @"yhlb":user.userType,
                                  @"loginID":user.loginID};

    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:requestDic urlString:[NSString stringWithFormat:@"%@/gd!updateGRXX.action",EDU_BASE_URL] finished:^(NSDictionary * dic){
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) { // 发送通知更换头像
            NSString * httpStr = FILE_SEVER_DOWNLOAD_URL;
            if ([httpStr containsString:@"https://"]) {
                httpStr = [httpStr stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
            }
            WDUser * user =  [WDUser sharedUser];
            user.avatar = [NSString stringWithFormat:@"%@/%@",httpStr,[headImageInfo objectForKey:@"fileId"]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

#pragma mark UiimagePickerDelegate
//回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self updateHeadImage:image];
    // 如果不加dismiss 是不会返回到调用ImagePicker界面的
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(NSString*)DataTOjsonString:(id)object {
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 2) { return ; }
    if(!self.imagePicker) { self.imagePicker = [UIImagePickerController new]; }
    
    self.imagePicker.delegate = self;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //设置动画
    self.imagePicker.allowsEditing = YES; //设置是否能缩放图片
    
    if (buttonIndex == 0) { // 照片库
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 1){ //拍照
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"当前设备不支持拍照功能", nil)];
            return ;
        }
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; //照片库
    }
    [self presentViewController: self.imagePicker animated:YES completion:nil];
}

@end
