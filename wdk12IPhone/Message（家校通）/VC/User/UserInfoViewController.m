#import "UserInfoViewController.h"
#import "DDUserModule.h"
#import "ContactModule.h"
#import "UIColor+Hex.h"
#import "IMBaseDefine.pb.h"
#import "ModifySingleInfo.h"
#import "UIImageView+WebCache.h"
#import "ChatVIewController.h"
#import "UIImage+FullScreen.h"
#import "WDDescView.h"
#import <Masonry.h>
#import "ViewSetUniversal.h"
#import "DDDatabaseUtil.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "avatarImageView.h"
@interface FullScrrenMaskView : FlyFullScreenMaskView

@property    UIView* origin;

@end
@implementation FullScrrenMaskView
-(id)init{
    self = [super init];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    return self;
}
-(void)setLinear:(CGFloat)linear{
    if(self.linear == linear) return;
    
    
    [super setLinear:linear];
    [self setNeedsDisplay];
}
-(void)start{
    _origin.hidden = YES;
}
-(void)end{
    _origin.hidden = NO;
}
-(void)dealloc{
}
-(void)drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context, 1.0);
    CGContextSetLineWidth(context, 1.0);//线的宽度
    CGFloat x = rect.size.width/2.0;
    CGFloat y = rect.size.height/2.0;
    CGFloat r = MAX(x,y);
    CGContextAddArc(context, r, r,r*(1+(M_SQRT2-0.5)*self.linear), 0, 2*M_PI, 0); //添加一个圆
    
    CGContextDrawPath(context, kCGPathFill); //绘制路径
}

@end



@implementation UserInfoViewController
{
    NSString* _uid;
    UITableView* _tableView;
    
    UIScrollView* _scorllview;
    DDUserEntity* _uentity;
    ContactInfoEntity* _centity;
    
    
//    UITableViewCell* _avatarcell;
    UITableViewCell* _telphoecell;
    UITableViewCell* _emailcell;
    UITableViewCell* _rmkcell;
    UITableViewCell *_rigstCell;
    UITableViewCell *_refuseCell;
    UITableViewCell *_symbolCell;//置顶
    UITableViewCell *_deleChatRecordCell;
    NSLayoutConstraint* _messageOrContactHeightConstraint;
    
    NSMutableArray* _dataModel;
    NSMutableArray*  _sessionModel;
    UIButton* _footLeftBtn;
    UIButton* _footRightBtn;
    WDDescView *_descView;
    
}

-(id)init{
    self = [super init];
    //    self.title = @"详细资料";
    // self.view.backgroundColor = [UIColor grayColor];
    
    [self initData];
    [self initViews];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UserUpdatedNotify:) name:DDNotificationUserUpdated object:nil];
    //暂时不被动更新
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(agreeFriendNotification) name:DDNotificationContactRefresh object:nil];
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = IMLocalizedString(@"详细资料", nil);
    
}
- (void)setIsContactVC:(BOOL)isContactVC {
    _isContactVC = isContactVC;
    if (!self.isContactVC && _uid != nil &&_refuseCell == nil) {
        [self initSessionCell];
    }
}
-(BOOL)inContact{
    return _centity&&[_centity isContactUser];
}
-(void)setUserID:(NSString*)uid{
    _uid = uid;
    _uentity =  [[ContactModule shareInstance]getUserInfoWithNotification:uid ForUpdate:YES];
    _centity = [[ContactModule shareInstance]GetContactInfoByID:_uid];
    if (!self.isContactVC && _uid != nil &&_refuseCell == nil) {
        [self initSessionCell];
    }
    if(_uentity) [self UserUpdated];
    [self ContactUpdated];
    [self stepFooterView];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)SetCellValue{
    
}
-(void)UserUpdated{
    _telphoecell.detailTextLabel.text = _uentity.telphone;
    _emailcell.detailTextLabel.text = _uentity.email;
    _rmkcell.detailTextLabel.text = _uentity.rmkname;
    _rigstCell.detailTextLabel.text = _uentity.name;
    _descView.nameLabel.text = _uentity.nick;
    _descView.autographLabel.text = _uentity.ps;
    [_descView.imageV sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(_uentity.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
}
-(void)UserUpdatedNotify:(NSNotification*)notification{
    NSString* uid = notification.object;
    if(![uid isEqualToString:_uid]) return;
    _uentity = [[DDUserModule shareInstance]getUserByID:_uid];
    if(_uentity) [self UserUpdated];
    _centity = [[ContactModule shareInstance]GetContactInfoByID:_uid];
    if(_centity) [self ContactUpdated];
}

-(void)ContactUpdated{
    

    if([self inContact] ){
        if(_centity) {
            _rmkcell.detailTextLabel.text = _centity.rmkname;
        }
        
        _footLeftBtn.tag = 1;
        [_footLeftBtn setTitle:[NSString stringWithFormat:@"\U0000e62f %@", IMLocalizedString(@"发消息", nil)] forState:UIControlStateNormal];
        if(!self.isContactVC){
            [_dataModel addObjectsFromArray:_sessionModel];
        }
        _footRightBtn.hidden = NO;
        [_footLeftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_tableView.tableFooterView.mas_centerX).offset(-90);
            make.width.equalTo(@100);
            make.top.equalTo(_tableView.tableFooterView).offset(10);
            make.height.equalTo(@40);
        }];
    }
    else {
        _footLeftBtn.tag = 0;
        [_footLeftBtn setTitle:[NSString stringWithFormat:@"\U0000e625 %@", @"Add to Contacts"] forState:UIControlStateNormal];
        for (NSDictionary *dict in _dataModel) {
            if (dict[@"cell"] == _rmkcell) {
                [_dataModel removeObject:dict];
                break;
            }
        }
        _footRightBtn.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        [_footLeftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_tableView.tableFooterView.mas_centerX);
            make.width.equalTo(@200);
            make.top.equalTo(_tableView.tableFooterView).offset(10);
            make.height.equalTo(@40);
        }];
    }
}

-(void)DelFromContact{
    [SVProgressHUD showWithStatus:IMLocalizedString(@"正在删除", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[ContactModule shareInstance]removeUserFromContact:_uid Block:^(NSError * error) {
        if(!error){

            [SVProgressHUD dismiss];
//            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestOpenSession object:nil userInfo:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error:%@,code:%ld",error.domain,error.code]];
        }
    }];
}
-(void)messageOrBtntap{
//        _footLeftBtn.backgroundColor = [UIColor ColorWithHexRGBA:@"#2DC99DFF"];
}
-(void)messageorBtnClickOutSide{
//        _footLeftBtn.backgroundColor = [UIColor ColorWithHexRGBA:@"#3DA99DFF"];
}
-(void)messageOrBtnClick{
//       _footLeftBtn.backgroundColor = [UIColor ColorWithHexRGBA:@"#3DA99DFF"];

    if(_footLeftBtn.tag == 1){

        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestOpenSession object:nil userInfo:nil];
        UIViewController* sessionVC = [ChatViewController initWithUserID:_uid];
        NSArray *vcs = self.navigationController.viewControllers;
        [self.navigationController setViewControllers:@[vcs[0],sessionVC] animated:YES];
    }
    else{
        [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeGradient];
        [[ContactModule shareInstance]addUserToContact:_uid Block:^(NSError * error) {
            if(!error){
                [SVProgressHUD showSuccessWithStatus:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
//                _centity = [[ContactModule shareInstance]GetContactInfoByID:_uid];
//                assert(_centity);
//                [self ContactUpdated];
            }
            else{
                if(error.code == ContactModifyRetCodeNeetverify){
                    [SVProgressHUD dismiss];
                    //需要发送验证
                    ModifySingleInfo* vc = [[ModifySingleInfo alloc]initWithModifyType:ModifySingleValueTypeVerify ObjectID:_uid DefaultValue:[NSString stringWithFormat:@"%@ %@",IMLocalizedString(@"我是", nil), TheRuntime.user.nick]];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
                    NSLog(@"error:%@ code:%ld:",error.domain,error.code);
                }
            }
        }];
    }
}
-(NSString*)UserID{
    return _uid;
}
-(void)avatarTap:(UIGestureRecognizer*)tapgesture{
    UIImageView* imageview = tapgesture.view;
    if(imageview && [imageview isKindOfClass:[UIImageView class]]){
        CGRect frame = imageview.frame;
        frame.origin.x = 0;frame.origin.y = 0;
        frame = [imageview convertRect:frame toView:nil];
        
        FullScrrenMaskView* view = [[FullScrrenMaskView alloc]init];
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        view.origin = imageview;
        [UIImage FlyFullScreenWithView :imageview.image OriginRect:frame  MaskView:nil];
    }
}
-(void)initData{
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lxfs"];
        cell.textLabel.text = IMLocalizedString(@"手机号", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        _telphoecell = cell;
    }
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lxfs"];
        cell.textLabel.text = IMLocalizedString(@"邮箱", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        _emailcell = cell;
    }
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"szbz"];
        UILabel *accessoryView = [UILabel new];
        accessoryView.font = [UIFont fontWithName:@"iconfont" size:20];
        accessoryView.textColor = [UIColor grayColor];
        accessoryView.text = @"  \U0000e623";
        [accessoryView sizeToFit];
        cell.accessoryView = accessoryView;
        cell.textLabel.text = IMLocalizedString(@"设置备注", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        _rmkcell = cell;
    }
    {//注册号显示cell
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"zch"];
        cell.textLabel.text = IMLocalizedString(@"帐号", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        _rigstCell = cell;
    }
    _dataModel = [NSMutableArray new];
   
    [_dataModel addObject:@{
                            @"cell" : _rigstCell,
                            @"height":@(40)
                            }];
    [_dataModel addObject:@{
                              @"cell" : _telphoecell,
                              @"height":@(40)
                              }];
    [_dataModel addObject:@{
                              @"cell" : _emailcell,
                              @"height":@(40)
                              }];
    
    [_dataModel addObject:@{
                          @"cell" : _rmkcell,
                          @"height":@(40)
                          }];
}
- (void)initSessionCell {
    SessionEntity *entity = [[SessionModule sharedInstance] getSessionById:_uid];

    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"refuse"];
        cell.textLabel.text = IMLocalizedString(@"消息免打扰", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        UIButton *refuseBtn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(switchValueChange:)];
        cell.accessoryView = refuseBtn;
        refuseBtn.selected = entity.isShield;
        _refuseCell = cell;
    }
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"symbol"];
        cell.textLabel.text = IMLocalizedString(@"置顶", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        UIButton *btn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(symbolCellSwitchValueChange:)];
        cell.accessoryView = btn;
        btn.selected = entity.topLevel;
        _symbolCell = cell;
    }
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"deleChat"];
        cell.textLabel.text = IMLocalizedString(@"清空聊天记录", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        _deleChatRecordCell = cell;
    }
    
    NSMutableArray* sessionModel = [NSMutableArray new];
    [sessionModel addObject:@{
                              @"cell" : _refuseCell,
                              @"height":@(40)
                              }];
    [sessionModel addObject:@{
                              @"cell" : _symbolCell,
                              @"height":@(40)
                              }];
    [sessionModel addObject:@{
                              @"cell" : _deleChatRecordCell,
                              @"height":@(40)
                              }];
    _sessionModel = sessionModel;
}
- (UIButton *)creatCellAccessorryButtonWithTitle:(NSString *)title selectedTitle:(NSString *)seleTitle fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor seleTextColor:(UIColor *)seleTextColor target:(id)target action:(SEL)action {
    
    UIButton *dndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [ViewSetUniversal setButton:dndBtn title:title fontSize:fontSize textColor:textColor fontName:fontName action:action target:target];
    [dndBtn setTitle:seleTitle forState:UIControlStateSelected];
    [dndBtn setTitleColor:seleTextColor forState:UIControlStateSelected];
    return dndBtn;
}
- (void)symbolCellSwitchValueChange:(UIButton *)sender {
    //置顶
    sender.selected = !sender.selected;
    SessionEntity *entity = [[SessionModule sharedInstance] getSessionById:_uid];
    [[SessionModule sharedInstance]topSession:entity Top:sender.isSelected];
}
- (void)switchValueChange:(UIButton *)sender {
    sender.selected = !sender.selected;
    SessionEntity *entity = [[SessionModule sharedInstance] getSessionById:_uid];
    [entity SessionDND:sender.isSelected?1:0];
}
-(void)initViews{
    
    _descView = [WDDescView descView];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTap:)];
    [_descView.imageV addGestureRecognizer:gesture];
    _descView.imageV.userInteractionEnabled = YES;
    [self.view addSubview:_descView];
    [_descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(84);
        make.left.right.offset(0);
        make.height.equalTo(@150);
    }];
    _descView.backgroundColor = [UIColor clearColor];
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(_descView.mas_bottom).offset(20);
    }];
    self.view.backgroundColor = COLOR_Creat(249, 249, 249, 1);
    _tableView.backgroundColor = self.view.backgroundColor;

    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,0, 60)];
    _footLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _footLeftBtn.backgroundColor = COLOR_Creat(94, 191, 109, 1);

    _footRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _footRightBtn.backgroundColor = COLOR_Creat(252, 102, 33, 1);
    [ViewSetUniversal setButton:_footLeftBtn title:[NSString stringWithFormat:@"\U0000e62f %@", IMLocalizedString(@"发消息", nil)] fontSize:14 textColor:nil fontName:@"iconfont" action:@selector(messageOrBtnClick) target:self];
    [ViewSetUniversal setButton:_footRightBtn title:[NSString stringWithFormat:@"\U0000e65a %@", IMLocalizedString(@"删除好友", nil)] fontSize:14 textColor:nil fontName:@"iconfont" action:@selector(DelFromContact) target:self];
    [ViewSetUniversal setView:_footRightBtn cornerRadius:3];
    [ViewSetUniversal setView:_footLeftBtn cornerRadius:3];
    [_tableView.tableFooterView addSubview:_footLeftBtn];
    [_tableView.tableFooterView addSubview:_footRightBtn];
//    [self stepFooterView];

}
- (void)stepFooterView {
    UIView* footview = _tableView.tableFooterView;
    if ([self inContact]) {
        //属于我的好友
      [_footLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerX.equalTo(footview.mas_centerX).offset(-90);
            make.width.equalTo(@100);
          make.top.equalTo(footview).offset(10);
            make.height.equalTo(@40);
        }];
        [_footRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(footview.mas_centerX).offset(20);
            make.width.equalTo(@100);
            make.top.equalTo(footview).offset(10);
            make.height.equalTo(@40);
        }];
        _footRightBtn.hidden = NO;
    } else {
        _footRightBtn.hidden = YES;
        [_footLeftBtn setTitle:[NSString stringWithFormat:@"\U0000e625 %@", IMLocalizedString(@"添加到通讯录", nil)] forState:UIControlStateNormal];
        [_footLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footview.mas_centerX);
            make.top.equalTo(footview).offset(10);
            make.width.equalTo(@200);
            make.height.equalTo(@40);
        }];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context  {
    
}

- (void)agreeFriendNotification {
    _uentity = [[DDUserModule shareInstance]getUserByID:_uid];
    if(_uentity) [self UserUpdated];
    _centity = [[ContactModule shareInstance]GetContactInfoByID:_uid];
    if(_centity) [self ContactUpdated];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataModel count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[_dataModel objectAtIndex:indexPath.row]objectForKey:@"cell" ];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[[_dataModel objectAtIndex:indexPath.row]objectForKey:@"height" ] floatValue];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == _rmkcell){
        ModifySingleInfo* vc = [[ModifySingleInfo alloc]initWithModifyType:ModifySingleValueTyperRmkname ObjectID:_uid
            DefaultValue:_centity.rmkname];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (_deleChatRecordCell == cell) {
        //清空聊天记录。。。
        SessionEntity* sentity = [[SessionModule sharedInstance]getSessionById:_uid];
        if(sentity){
            [[DDUserModule shareInstance] clearLocalMessage:_uid];
            [[SessionModule sharedInstance]clearSession:sentity];
            ChatViewController *vc = [ChatViewController initWithGroupID:_uid];
            [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],vc] animated:YES];
            [SVProgressHUD showSuccessWithStatus:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
        }
    }
    
}
@end
