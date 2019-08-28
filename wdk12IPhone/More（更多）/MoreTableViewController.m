//
//  MoreTableViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//
#import "MoreTableViewController.h"
#import "MoreHeaderView.h"
#import "PersonalInformation.h"
#import "ModifyPasswordViewController.h"
#import "MyClassViewController.h"
#import "mySettingViewController.h"
#import "UIImageView+WebCache.h"
#import "HelpViewController.h"

@interface MoreTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
///  显示内容的数据源
@property (nonatomic, strong) NSArray *dataSource;
///  选择后的数据源
@property (nonatomic, strong) NSArray *selectData;
///  背景view
@property (nonatomic, strong) UIView *headerView;
///  头像
@property (nonatomic, strong) UIImageView *imageView;
///  教师名称
@property (nonatomic, strong) UILabel *nameLabel;
///  设置
@property (nonatomic, strong) UIButton *setButton;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initAutoLayout];
    [self initTableView];
}

- (void)initView {
    self.headerView = [UIView viewWithBackground:[UIColor hex:0x238B6D alpha:1.0] alpha:1.0];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"555555"]];
    self.nameLabel = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:18] alpha:1.0];
    self.setButton = [UIButton new];
    [self.setButton setImage:[UIImage imageNamed:@"555555"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.imageView];
    [self.headerView addSubview:self.nameLabel];
    [self.headerView addSubview:self.setButton];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[WDUser sharedUser].avatar] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
//    self.imageView.image = [UIImage imageNamed:@"sessionshield"];
    self.nameLabel.text = [WDUser sharedUser].userName;
    [self.setButton addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initAutoLayout {
    self.headerView.bounds = CGRectMake(0, 0, [UIScreen wd_screenWidth], 200);
    [self.imageView zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.headerView size:CGSizeMake(80, 80) offset:CGPointZero];
    [self.nameLabel zk_AlignVertical:ZK_AlignTypeBottomCenter referView:self.imageView size:CGSizeZero offset:CGPointMake(0, 10)];
    [self.setButton zk_AlignInner:ZK_AlignTypeTopRight referView:self.headerView size:CGSizeMake(30, 30) offset:CGPointMake(-10, 10)];
}

- (void)initTableView {
    self.tableView = [UITableView new];
    [self.view addSubview:self.tableView];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    //隐藏多余横线
    self.tableView.tableFooterView = [UIView new];
//    self.navigationController.navigationBar.backgroundColor = [UIColor hex:0x238B6D alpha:1.0];
    
    
}
- (void)settingBtnClick {
    
    mySettingViewController * settingVc = [[mySettingViewController alloc]init];
    [settingVc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:settingVc animated:YES];
}

//隐藏电池栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    WDUser * user =  [WDUser sharedUser];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
}

#pragma mark - tableView delegate and dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"iconfont" size:18];
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.selectData.count) {
        [self pushViewControllerWithClass:self.selectData[indexPath.row]];
    }
}

/*!
 *  显示所需要的控制器
 *
 *  @param ClassVC 控制器类型
 */
- (void)pushViewControllerWithClass:(Class)ClassVC {
    UIViewController *vc = [ClassVC new];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (NSArray *)dataSource {
    return @[[NSString stringWithFormat:@"\U0000E623  %@", NSLocalizedString(@"个人信息", nil)],
             [NSString stringWithFormat:@"\U0000E615  %@", NSLocalizedString(@"修改密码", nil)],
//             [NSString stringWithFormat:@"\U0000E671  %@", NSLocalizedString(@"使用帮助", nil)],
             [NSString stringWithFormat:@"\U0000E61b  %@", NSLocalizedString(@"我的班级", nil)]];
}

- (NSArray *)selectData {
    return @[[PersonalInformation class], [ModifyPasswordViewController class], /*[HelpViewController class],*/ [MyClassViewController class]];
}

@end
