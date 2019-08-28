//
//  MessageViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "MessageViewController.h"
#import "SessionTableView.h"
#import "uicolor+hex.h"
#import "DDClientState.h"
#import "ContactTableView.h"
#import "anchorView.h"
#import "FriendVerifyListViewController.h"
#import "GroupListViewController.h"
#import "UserInfoViewController.h"
#import "SearchUserViewController.h"
#import "ModifyGroupMemberViewController.h"
#import "WDSegementView.h"
#import "ChatViewController.h"
#import "sessionCell.h"
#import "ContactModule.h"
#import "DDClientState.h"
#import "DDTcpClientManager.h"
#import "SubcripeSessionVC.h"
#import "SessionModule.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import "MessageSendModule.h"
#import "SubscribeListVC.h"
#import "IMAddContactVC.h"
#import "LoginModule.h"
#import "ViewSetUniversal.h"
#define SEG_HEIGHT 49
#define SEG_WHITE_HEIGHT 0

#define IM_TITIE IMLocalizedString(@"家校通", nil)

@interface MessageViewController ()<UINavigationControllerDelegate,UITabBarControllerDelegate>

//主界面
@property UIView* contentView;
//@property NSLayoutConstraint* contentBottomConstraint;
//@property NSLayoutConstraint* contentTopConstraint;

//@property UISegmentedControl* segctrl;

@property UILabel* netView;

@property WDSegmentView* segctrl;
@property UIView* transView;
//消息
@property UIView* messagesView;
@property SessionTableView* sessionTableView;
//通讯录
@property UIView* contactView;
@property ContactTableView* contactTableView;

//title
@property UILabel* titleView;
@property UIActivityIndicatorView* indicator;

//popup
@property  AnchorView* anchorview;
@property  UIView*     anchorBGView;

@end
@implementation MessageViewController
{
    BOOL _reg;
    BOOL _isAnchorAnimate;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    self.navigationController.delegate = self;
    self.tabBarController.delegate = self;
    _reg = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor  =  [UIColor ColorWithHexRGBA:@"#FFFFFFFF"];
    [self initTitleView];
    //初始化content
    [self initContentView];
    //初始化seg
    [self initSegView];
    //初始化transview
    [self initTransView];
    
    [self initMessageView];
    [self initContactView];
    //右上角的小列表
    //    [self initPopUpView];
    //    [self initNetView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginSuccess) name:DDNotificationUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginFailure) name:DDNotificationUserLoginFailure object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Logining) name:DDNotificationStartLogin object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LocalPrepared) name:DDNotificationLocalPrepared object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ContactRefreshed) name:DDNotificationContactRefresh object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RequestOpenSession:) name:DDNotificationRequestOpenSession object:nil];
    
    [[DDClientState shareInstance]addObserver:self forKeyPath:DD_USER_STATE_KEYPATH options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if([DDClientState shareInstance].userState != DDUserOnline){
        //        _netView.hidden = NO;
        [self setTitleSuffix:IMLocalizedString(@"未连接", nil) WithIndicator:NO];
        [self.view bringSubviewToFront:_netView];
    }
    else{
        [self setTitleSuffix:@"" WithIndicator:NO];
        //        _netView.hidden = YES;
    }
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count > 1) {
        //影响后面push的vc
        [viewController setHidesBottomBarWhenPushed:YES];
        //显示当前控制器的tabbar,为了解决边角手势拖动的问题
        [self setHidesBottomBarWhenPushed:NO];
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1) {
        //隐藏push控制器的tabbar
        [self setHidesBottomBarWhenPushed:YES];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    //在切换tabBar控制器的时候，防止隐藏tabBar
    [self setHidesBottomBarWhenPushed:NO];
}
#pragma mark INIT_VIEW
-(void)initNetView{
    _netView = [[UILabel alloc]init];
    _netView.frame = CGRectMake(0, 64, self.view.frame.size.width, 30);
    _netView.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    _netView.text = IMLocalizedString(@"当前网络不可用，请检查你的网络设置", nil);
    _netView.textColor = [UIColor grayColor];
    _netView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_netView];
}
-(void)initTitleView{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _titleView =  [[UILabel alloc]init];
    [self.navigationItem.titleView addSubview:_titleView];
    _titleView.textColor = [UIColor whiteColor];
    _titleView.text = IMLocalizedString(IM_TITIE, nil);
    [_titleView sizeToFit];
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.navigationItem.titleView addSubview:_indicator];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.offset(0);
    }];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [ViewSetUniversal setButton:btn title:@"\U0000e659" fontSize:20 textColor:[UIColor whiteColor] fontName:@"iconfont" action:@selector(rightBarbuttonItemClick) target:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    [self updateSockState];
}
-(void)updateSockState{
    if([DDClientState shareInstance].networkState == DDNetWorkDisconnect){
        [self setTitleSuffix:IMLocalizedString(@"未连接", nil) WithIndicator:NO];
    }
    switch ([LoginModule instance].loginState) {
        case LoginStateLoginIng:
            [self setTitleSuffix:IMLocalizedString(@"未连接", nil) WithIndicator:YES];
            break;
        case LoginStateLoginSuccess:
            [self setTitleSuffix:@"" WithIndicator:NO];
            break;
        case  LoginStateLoginFailure:
            [self setTitleSuffix:IMLocalizedString(@"未连接", nil) WithIndicator:NO];
    }
}
-(void)initContentView{
    _contentView = [[UIView alloc]init];
    _contentView.backgroundColor = [UIColor ColorWithHexRGBA:@"#FFFFFFFF"];
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.left.right.offset(0);
    }];
}
-(void)initSegView{
    _segctrl = [[WDSegmentView alloc]initWithTitles:@[IMLocalizedString(@"会话", nil),IMLocalizedString(@"通讯录", nil)] SliderLineHeihgt:4.0];
    [_contentView addSubview:_segctrl];
    [_segctrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.equalTo(_contentView);
        make.top.offset(64);
        make.height.offset(SEG_HEIGHT);
    }];
    [_segctrl setFont:[UIFont systemFontOfSize:20]];
    [_segctrl setNormalTextColor:[UIColor lightGrayColor]];
    [_segctrl setSelectedTextColor:[UIColor ColorWithHexRGBA:@"#3DA99DFF"]];
    
    [_segctrl setTarget:self Action:@selector(segAction1:)];
}
-(void)initTransView{
    
    _transView = [[UIView alloc]init];
    [_contentView addSubview:_transView];
    [_transView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.offset(0);
        make.top.equalTo(_segctrl.mas_bottom);//.offset(SEG_HEIGHT);
        make.width.equalTo(_contentView).multipliedBy(2);
    }];
    
}
-(void)initMessageView{
    _messagesView = [UIView new];
    _messagesView.backgroundColor = [UIColor ColorWithHexRGBA:@"#FF0000FF"];
    [_transView addSubview:_messagesView];
    [_messagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(_transView);
        make.width.equalTo(_transView).multipliedBy(0.5);
        
    }];
    
    _sessionTableView = [SessionTableView new];
    _sessionTableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    [_messagesView addSubview:_sessionTableView];
    
    [_sessionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_messagesView);
    }];
    _sessionTableView.Sessiondelegate = self;
}
-(void)initContactView{
    _contactView = [UIView new];
    //    _contactView.backgroundColor = [UIColor ColorWithHexRGBA:@"#00FF00FF"];
    _contactView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_transView addSubview:_contactView];
    [_contactView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_messagesView.mas_right);
        make.width.equalTo(_transView).multipliedBy(0.5);
        make.top.bottom.equalTo(_transView);
    }];
    _contactTableView = [ContactTableView new];
    _contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    [_contactView addSubview:_contactTableView];
    [_contactTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.offset(0);
    }];
    _contactTableView.contactTableViewdelegate = self;
}
//-(void)initPopUpView{
//    _anchorBGView = [[UIView alloc]init];
//    _anchorBGView.userInteractionEnabled = YES;
//    [self.view addSubview:_anchorBGView];
//    _anchorBGView.translatesAutoresizingMaskIntoConstraints = NO;
//    [_anchorBGView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
//    [_anchorBGView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
//    [_anchorBGView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
//    [_anchorBGView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
//
//    CGFloat popwidth = 120.0;
//    CGFloat left = self.view.frame.size.width-popwidth-2;
//
//    _anchorview = [[AnchorView alloc]initWithFrame:CGRectMake(left,64, popwidth, 100)];
//    _anchorview.backgroundColor = [UIColor clearColor];
//    //[self.view addSubview:_anchorview];
//
//    _anchorview.anchorForward = AnchorForwardTop;
//    _anchorview.start = 0.77;
//    _anchorview.end = 0.87;
//    _anchorview.anthor = 0.82;
//    _anchorview.anchorForward = AnchorForwardTop;
//    _anchorview.tmargin = 10.0;
//
//    _anchorview.th = 5.0;
//
//
//    _anchorview.hidden = YES;
//    _anchorBGView.hidden = YES;
//    _anchorview.delegate = self;
//    [_anchorview ReloadCell];
//    [_anchorBGView addSubview:_anchorview];
//    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onAnchorBGTap)];
//    [_anchorBGView addGestureRecognizer:gesture];
//    UISwipeGestureRecognizer* gestureswip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onAnchorBGTap)];
//    gestureswip.direction =     UISwipeGestureRecognizerDirectionRight|
//    UISwipeGestureRecognizerDirectionLeft|
//    UISwipeGestureRecognizerDirectionUp |
//    UISwipeGestureRecognizerDirectionDown;
//    [_anchorBGView addGestureRecognizer:gestureswip];
//
//    UIPanGestureRecognizer* gesturepan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onAnchorBGTap)];
//    [_anchorBGView addGestureRecognizer:gesturepan];
//}
#pragma mark ACTION

-(void)segAction1:(NSInteger)index{
    switch(index){
        case 1:[self MoveToContactView:YES];
            break;
        case 0:[self MoveToMessageView:YES];
            break;
        default:break;
    }
}
-(void)segAction:(id)sender{
    UISegmentedControl* seg = sender;
    
    if(!seg) return;
    
    switch(seg.selectedSegmentIndex){
        case 1:[self MoveToContactView:YES];
            break;
        case 0:[self MoveToMessageView:YES];
            break;
        default:break;
    }
    
}
//-(void)onAnchorBGTap{
//    if(_anchorBGView.isHidden) return;
//    [self ToggleAnchorView:YES];
//}
//-(void)ToggleAnchorView:(BOOL)animate{
//    if(_isAnchorAnimate) return;
//    _isAnchorAnimate = YES;
//    if(!animate){
//
//        _anchorview.hidden = !_anchorview.hidden;
//        _anchorBGView.hidden = _anchorview.hidden;
//        _isAnchorAnimate = NO;
//        return;
//    }
//    if(_anchorview.isHidden){
//        _anchorview.hidden = NO;
//        _anchorBGView.hidden = NO;
//        _isAnchorAnimate = NO;
//    }
//    else{
//        CGFloat xoffset = _anchorview.frame.size.width*(_anchorview.anthor-0.5);
//        CGFloat yoffset = _anchorview.frame.size.height*0.5;
//        [UIView animateWithDuration:0.4 animations:^{
//            //_anchorview.transform = CGAffineTransformMakeScale(0.1, 0.1);
//            _anchorview.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(xoffset, -yoffset), 0.1, 0.1);
//            _anchorview.alpha = 0;
//        } completion:^(BOOL finished) {
//            _anchorview.hidden = YES;
//            _anchorBGView.hidden = YES;
//            _anchorview.alpha = 1;
//            _anchorview.transform = CGAffineTransformIdentity;
//            _isAnchorAnimate = NO;
//        }];
//    }
//}
//-(void)addAction:(id)sender{
//    [self ToggleAnchorView:YES];
//
//}
- (void)rightBarbuttonItemClick {
    //跳转添加联系人控制器。。。
    IMAddContactVC *vc = [[IMAddContactVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark SEG_CTRL
-(void)MoveToMessageView:(BOOL)animated{
    if(animated){
        [UIView beginAnimations:nil context:nil];
    }
    
    float transviewwidth = _transView.frame.size.width;
    _transView.transform = CGAffineTransformMakeTranslation(0, 0);
    if(animated){
        [UIView commitAnimations];
    }
    
    
}
-(void)MoveToContactView:(BOOL)animated{
    if(animated){
        [UIView beginAnimations:nil context:nil];
    }
    
    float transviewwidth = _transView.frame.size.width;
    _transView.transform = CGAffineTransformMakeTranslation(-transviewwidth/2.0, 0);
    
    if(animated){
        [UIView commitAnimations];
    }
}

#pragma mark title_view
-(void)setTitleSuffix:(NSString*) suffix WithIndicator:(BOOL)indicator{
    if(suffix == nil || [suffix isEqualToString:@""]){
        _titleView.text = IMLocalizedString(IM_TITIE, nil);
    }
    else{
        _titleView.text = [NSString stringWithFormat:@"%@(%@)",IMLocalizedString(IM_TITIE, nil), suffix];
    }
    if(indicator) [_indicator startAnimating];
    else [_indicator stopAnimating];
}
-(void)setTitleSuffix:(NSString*) suffix{
    if(suffix == nil || [suffix isEqualToString:@""]){
        _titleView.text = IMLocalizedString(IM_TITIE, nil);
        [_indicator stopAnimating];
    }
    else{
        _titleView.text = [NSString stringWithFormat:@"%@(%@)",IMLocalizedString(IM_TITIE, nil), suffix];
        [_indicator startAnimating];
    }
    
}



#pragma mark notify
-(void)LoginSuccess{
    [self setTitleSuffix:nil];
    
    [[ContactModule shareInstance]updateAvatar:[WDUser sharedUser].avatarFileID];
    
    [[ContactModule shareInstance]updatePS:[WDUser sharedUser].PS];
}
-(void)LoginFailure{
    [self setTitleSuffix:IMLocalizedString(@"未连接", nil) WithIndicator:NO];
}
-(void)Logining{
    [self setTitleSuffix:IMLocalizedString(@"连接中", nil)];
}
-(void)LocalPrepared{
    NSLog(@"local prepared");
    [_contactTableView reloadData];
    [_sessionTableView reloadData];
}
-(void)ContactRefreshed{
#warning 这里先注释
    //    NSLog(@"contact refreshed");
    [_contactTableView reloadData];
}

-(void)RequestOpenSession:(NSNotification*)notification{
    
    [self MoveToMessageView:NO];
    [_segctrl setSelectWithIndex:0 Animated:NO];
}
#pragma mark anchorDELEGATE
-(NSInteger)numCells{
    return 2;
}
-(void)viewForCell:(NSInteger)idx View:(UIView *)view{
    NSString* title = nil;
    if(idx == 0) title = IMLocalizedString(@"查找新朋友", nil);
    if(idx == 1) title = IMLocalizedString(@"新建会话组", nil);
    UIImageView* imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupsession"]];
    [view addSubview:imageview];
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(10);
        make.width.height.equalTo(view).offset(-20);
    }];
    
    UILabel* label = [[UILabel alloc]init];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13.0];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(view);
        make.left.equalTo(imageview.mas_right).offset(10);
    }];
}
-(void)cellTouched:(NSInteger)idx{
    
    if(idx == 1){
        ModifyGroupMemberViewController* controller = [[ModifyGroupMemberViewController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(idx == 0){
        SearchUserViewController* controller = [[SearchUserViewController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        assert(0);
    }
}

#pragma mark CONTACT_DELEGATE
-(void)NewFriendTouched{
    
    FriendVerifyListViewController* controller = [[FriendVerifyListViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)GroupTouched{
    GroupListViewController* controller = [[GroupListViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)UserTouched:(NSString *)uid{
    
    UserInfoViewController* controller = [[UserInfoViewController alloc]init];
    // [controller setUserID:uid];
    controller.isContactVC = YES;
    controller.UserID = uid;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)SubscribeTouched {
    SubscribeListVC *vc = [SubscribeListVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark SESSION_DELEGATE
-(void)SessionTouched:( SessionCell* _Nonnull)sessioncell{
    ChatViewController* vc = [ChatViewController initWithSessionEntity:sessioncell.sessionEntity];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)SubscribeSectionTouched {
    SubcripeSessionVC *vc = [SubcripeSessionVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if(_reg){
        [[DDClientState shareInstance]removeObserver:self forKeyPath:DD_USER_STATE_KEYPATH];
        
        [[DDTcpClientManager instance]disconnect];
        [DDClientState shareInstance].userState = DDUserOffLineInitiative ;
        [[SessionModule sharedInstance]clear];
        [[ContactModule shareInstance]clear];
        [[DDGroupModule instance]clear];
    }
}
@end
