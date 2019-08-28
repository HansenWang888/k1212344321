#import "SessionDetailViewController.h"
#import "SessionEntity.h"
#import "DDUserModule.h"
#import "DDUserEntity.h"
#import "DDGroupModule.h"
#import "GroupEntity.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "UserInfoViewController.h"
#import "ModifyGroupMemberViewController.h"
#import "ModifySingleInfo.h"
#import "ContactModule.h"
#import "UIImage+FullScreen.h"
#import "SessionModule.h"
#import "ReportViewController.h"
#import "QuitGroupapi.h"
#import <Masonry.h>
#import "ViewSetUniversal.h"
#import "WDDescView.h"
#import "ChatVIewController.h"
#import <UIImageView+WebCache.h>

@implementation AvatarNickCell

-(void)setUserID:(NSString*)uid WithGroup:(NSString*)gid{
    [_avatarImageView setUid:uid];
    [_groupNameLabel setUid:uid];
}

@end
//想不起起啥名了，就叫宇宙吧
typedef void(^SetUniverseBlock)(AvatarNickCell*);
typedef void(^TouchUniverseBlock)(AvatarNickCell*);

typedef void(^Action)();

@interface SessionDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SessionDetailViewController
{
    UIView* _headerView;
    UICollectionView* _memberAvatarsView;
    
    NSMutableArray<NSMutableDictionary*>* _dataModel;

    NSMutableArray<NSDictionary*>* _others;

    UITableViewCell* _session_DND_Cell;
    UITableViewCell* _session_TOP_Cell;
    UITableViewCell* _group_contact_Cell;
    UITableViewCell* _group_ShowNick_Cell;
    UITableViewCell* _group_SetName_Cell;
    UITableViewCell* _group_mynick_Cell;
    UITableViewCell* _reportCell;
    UITableViewCell *_deleChatRecordCell;
    WDDescView *_descView;
    BOOL _coreg;
    NSString *_groupID;
    SessionEntity* _sentity;
}
-(id)initWithSession:(SessionEntity*)sentity{
    
    self = [super init];
    _sentity = sentity;
    _groupID = sentity.sessionID;

    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_Creat(249, 249, 249, 1);
    _descView = [WDDescView descView];
    [_descView.autographLabel removeFromSuperview];
    [self.view addSubview:_descView];
    [_descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(84);
        make.left.right.offset(0);
        make.height.equalTo(@130);
    }];
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(_descView.mas_bottom).offset(20);
    }];
    _tableView.backgroundColor = self.view.backgroundColor;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGroupUpdate:) name:DDNotificationGroupUpdated object:nil];
    
    [self initData];
}
- (instancetype)initWIthGroupID:(NSString *)groupID {
    if (self = [super init]) {
        _groupID = groupID;
        _descView = [WDDescView descView];
        [_descView.autographLabel removeFromSuperview];
        [self.view addSubview:_descView];
        [_descView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(84);
            make.left.right.offset(0);
            make.height.equalTo(@130);
        }];
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_descView.mas_bottom).offset(20);
        }];
        self.view.backgroundColor = COLOR_Creat(249, 249, 249, 1);
        _tableView.backgroundColor = self.view.backgroundColor;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGroupUpdate:) name:DDNotificationGroupUpdated object:nil];
        
        [self initData];

    }
    return self;
}
-(void)dealloc{
    [_memberAvatarsView removeObserver:self forKeyPath:@"contentSize"];
}
- (UILabel *)creatAccessoryViewCell {
    UILabel *accessoryView = [UILabel new];
    accessoryView.font = [UIFont fontWithName:@"iconfont" size:20];
    accessoryView.textColor = [UIColor grayColor];
    accessoryView.text = @"  \U0000e623";
    [accessoryView sizeToFit];
    return accessoryView;
}
-(void)initData{
    _dataModel = [[NSMutableArray alloc]init];
    //群组会话
    _session_DND_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello world"];
    _session_DND_Cell.textLabel.text = IMLocalizedString(@"消息免打扰", nil);
    UIButton *dndBtn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(onDND:)];
    _session_DND_Cell.accessoryView = dndBtn;
    
    _session_TOP_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello world"];
    _session_TOP_Cell.textLabel.text = IMLocalizedString(@"置顶会话", nil);
    UIButton *topBtn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(onTop:)];
    _session_TOP_Cell.accessoryView = topBtn;
    _group_SetName_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hello world"];
    _group_SetName_Cell.textLabel.text = IMLocalizedString(@"群名称", nil);
    _group_SetName_Cell.detailTextLabel.text = @"";
    _group_SetName_Cell.accessoryView = [self creatAccessoryViewCell];
    dndBtn.selected = _sentity.isShield;
    topBtn.selected = _sentity.topLevel;
    Action setNameblock = ^(){
        ModifySingleInfo* vc = [[ModifySingleInfo alloc]initWithModifyType:ModifySingleValueTypeGroupName ObjectID:_sentity.sessionID DefaultValue:_group_SetName_Cell.detailTextLabel.text];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    };
    
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_group_SetName_Cell,@"h":@(44),@"action":setNameblock}]];
    
    _group_mynick_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hello world"];
    _group_mynick_Cell.textLabel.text = IMLocalizedString(@"我的群昵称", nil);
    _group_mynick_Cell.detailTextLabel.text = @"";
    _group_mynick_Cell.accessoryView = [self creatAccessoryViewCell];
    
    Action setNickblock = ^(){
        ModifySingleInfo* vc = [[ModifySingleInfo alloc]initWithModifyType:ModifySingleValueTypeGroupMyNick ObjectID:_sentity.sessionID DefaultValue:_group_mynick_Cell.detailTextLabel.text];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    };
    
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_group_mynick_Cell,@"h":@(44),@"action":setNickblock}]];

    
    _group_contact_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello world"];
    _group_contact_Cell.textLabel.text = IMLocalizedString(@"添加到通讯录", nil);
    UIButton *groupBtn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(onsaveContact:)];
    _group_contact_Cell.accessoryView = groupBtn;
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_group_contact_Cell,@"h":@(44)}]];
    _group_ShowNick_Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello world"];
    
    _group_ShowNick_Cell.textLabel.text = IMLocalizedString(@"显示群组内昵称", nil);
    UIButton *showNickBtn = [self creatCellAccessorryButtonWithTitle:@"\U0000e662" selectedTitle:@"\U0000e663" fontSize:45 fontName:@"iconfont" textColor:[UIColor grayColor] seleTextColor:COLOR_Creat(28, 203, 114, 1) target:self action:@selector(onShowNick:)];

    _group_ShowNick_Cell.accessoryView = showNickBtn;
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_group_ShowNick_Cell,@"h":@(44)}]];
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_session_DND_Cell,@"h":@(44)}]];
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_session_TOP_Cell,@"h":@(44)}]];
    [self stepCollectionView];
    [self stepFooterView];
    _reportCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello world"];
    _reportCell.textLabel.text = IMLocalizedString(@"举报", nil);
    _reportCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIView *cellLine = [[UIView alloc] initWithFrame:CGRectMake(15, 43, self.view.bounds.size.width, 1)];
    cellLine.backgroundColor = [UIColor lightGrayColor];
    [_reportCell.contentView addSubview:cellLine];
    Action report_block = ^(){
        ReportViewController* vc = [[ReportViewController alloc]initWithSession:_sentity];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_reportCell,@"h":@(44),@"action":report_block}]];
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"deleChat"];
    cell.textLabel.text = IMLocalizedString(@"清空聊天记录", nil);
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    _deleChatRecordCell = cell;
    Action dele_report_block = ^(){
       //清空聊天记录。。。
        SessionEntity* sentity = [[SessionModule sharedInstance]getSessionById:_groupID];
        if(sentity){
            [[DDGroupModule instance] clearLocalMessage:_groupID];
            [[SessionModule sharedInstance]clearSession:sentity];
            ChatViewController *vc = [ChatViewController initWithGroupID:_groupID];
            [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],vc] animated:YES];
            [SVProgressHUD showSuccessWithStatus:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"操作失败"];
        }
    };
    [_dataModel addObject:[[NSMutableDictionary alloc]initWithDictionary:@{@"cell":_deleChatRecordCell,@"h":@(44),@"action":dele_report_block}]];

    [self initMemberDataModel];
    [self initGroupData];
}
- (UIButton *)creatCellAccessorryButtonWithTitle:(NSString *)title selectedTitle:(NSString *)seleTitle fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor seleTextColor:(UIColor *)seleTextColor target:(id)target action:(SEL)action {
    
    UIButton *dndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [ViewSetUniversal setButton:dndBtn title:title fontSize:fontSize textColor:textColor fontName:fontName action:action target:target];
    [dndBtn setTitle:seleTitle forState:UIControlStateSelected];
    [dndBtn setTitleColor:seleTextColor forState:UIControlStateSelected];
    return dndBtn;
}

- (void)stepFooterView {
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 64)];
    UIView* footview = self.tableView.tableFooterView;
    UIButton* quitbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.backgroundColor = COLOR_Creat(94, 191, 109, 1);
    [ViewSetUniversal setView:sendBtn cornerRadius:3];
    [ViewSetUniversal setButton:sendBtn title:[NSString stringWithFormat:@"\U0000e62f %@", IMLocalizedString(@"发消息", nil)] fontSize:14 textColor:nil fontName:@"iconfont" action:@selector(sendMessageBtnClick) target:self];
    [footview addSubview:sendBtn];
    [footview addSubview:quitbtn];
    quitbtn.backgroundColor = COLOR_Creat(252, 102, 33, 1);
    if (_sentity.sessionType == SessionTypeSessionTypeGroup) {
        [ViewSetUniversal setButton:quitbtn fontAttr:@"\U0000e65a" fontSize:14 textColor:[UIColor whiteColor] contentAttr:IMLocalizedString(@"退出该组", nil) action:@selector(onQuitGroup) target:self];
        
    } else {
        [ViewSetUniversal setButton:quitbtn title:[NSString stringWithFormat:@"\U0000e624 %@", IMLocalizedString(@"删除好友", NIL)] fontSize:14 textColor:nil fontName:@"iconfont" action:@selector(deleFirend) target:self];
    }
    [ViewSetUniversal setView:quitbtn cornerRadius:3];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(footview.mas_centerX).offset(-20);
        make.centerY.equalTo(footview.mas_centerY).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(footview.mas_height).offset(-30);
    }];
    [quitbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footview.mas_centerX).offset(20);
        make.centerY.equalTo(footview.mas_centerY).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(footview.mas_height).offset(-30);
    }];
}
- (void)stepCollectionView {
    //成员头像
    UICollectionViewFlowLayout* flowlayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowlayout.itemSize = CGSizeMake(64, 84);
    flowlayout.headerReferenceSize = CGSizeZero;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _memberAvatarsView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 104) collectionViewLayout:flowlayout];
    
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CURRENT_DEVICE_SIZE.width, 104)];
    _headerView.backgroundColor = COLOR_Creat(249, 249, 249, 1);
    UIView *topLine = [UIView new];
    topLine.backgroundColor = [UIColor lightGrayColor];
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [_headerView addSubview:topLine];
    [_headerView addSubview:bottomLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.offset(0);
        make.left.offset(0);
        make.height.equalTo(@1);
    }];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.offset(0);
        make.left.offset(0);
        make.height.equalTo(@1);
    }];
    [_headerView addSubview:_memberAvatarsView];
    
    [_memberAvatarsView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    _memberAvatarsView.backgroundColor = [UIColor clearColor];
    _memberAvatarsView.scrollEnabled = NO;
//    _memberAvatarsView.opaque = YES;
    [_memberAvatarsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.right.offset(0);
    }];
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, CURRENT_DEVICE_SIZE.width -8, 104);
    _memberAvatarsView.dataSource = self;
    _memberAvatarsView.delegate = self;
}
-(void)initGroupData{
    GroupEntity* gentity = nil;
    if (_sentity) {
        //根据群组会话设设置
        gentity = [[DDGroupModule instance]getGroupInfoFromServerWithNotify:_sentity.sessionID Forupdate:NO];
        //下面三个属于有群组会话时才处理
        UIButton* groupBtn = (UIButton*)_group_ShowNick_Cell.accessoryView;
        [groupBtn setSelected:_sentity.showNick!=0];
       
        UIButton *dndBtn = (UIButton *)_session_DND_Cell.accessoryView;
        dndBtn.selected = _sentity.isShield;
        
         UIButton* topBtn = (UIButton*)_session_TOP_Cell.accessoryView;
        [topBtn setSelected:_sentity.topLevel!=0];

    } else {
        gentity = [[DDGroupModule instance] getGroupByGId:_groupID];
    }
    if(!gentity) return;
    _group_SetName_Cell.detailTextLabel.text = gentity.name;
    NSString *nickName = [gentity getGroupNick:TheRuntime.user.objID];
    if (nickName.length == 0) {
        nickName = TheRuntime.user.nick;
    }
    _group_mynick_Cell.detailTextLabel.text = nickName;
    [_descView.imageV setGroupID:gentity.objID];
    _descView.nameLabel.text = gentity.name;
    BOOL gincontact = [[ContactModule shareInstance]IsContactGroup:_groupID ? _groupID : _sentity.sessionID];
     UIButton* contactBtn = (UIButton *)_group_contact_Cell.accessoryView;
    [contactBtn setSelected:gincontact];
 
   }
-(void)initMemberDataModel{
    _others = [NSMutableArray new];
    
    BOOL couldadd = NO;
    BOOL coulddim = NO;
    GroupEntity* gentity = nil;
    if (_sentity) {
        //根据群组会话设设置
        gentity = [[DDGroupModule instance]getGroupInfoFromServerWithNotify:_sentity.sessionID Forupdate:NO];
    } else {
        gentity = [[DDGroupModule instance] getGroupByGId:_groupID];
    }
    if(!gentity) return;

    self.title = [NSString stringWithFormat:@"%@(%ld)",IMLocalizedString(@"聊天信息", nil), gentity.groupUserIds.count];
    
    WEAKSELF(self);
    for(NSInteger i = 0 ; i < gentity.groupUserIds.count ;++i){
        
        NSString* uid = gentity.groupUserIds[i];
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){
            [cell setUserID:uid WithGroup:_sentity.sessionID];
        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            if([uid isEqualToString:TheRuntime.user.objID]) return ;
            UserInfoViewController* vc = [[UserInfoViewController alloc]init];
            vc.isContactVC = NO;
            [vc setUserID:uid];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        };
        
        [_others addObject:@{@"set":setblock,@"touch":touchblock}];
        
        //可添加
        if(!couldadd && [uid isEqualToString:TheRuntime.user.objID]) couldadd = YES;
        
    }
    if([gentity.groupCreatorId isEqualToString:TheRuntime.user.objID]){
        coulddim = YES;
    }
    

      if(couldadd){
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){
            [cell.avatarImageView setImage:[UIImage imageNamed:@"sessionplus"]];
            [cell.avatarImageView setTintColor:[UIColor lightGrayColor]];
            cell.groupNameLabel.text = @"";
        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            
            ModifyGroupMemberViewController* vc = [[ModifyGroupMemberViewController alloc]initWithSession:_sentity];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        };
         [_others addObject:@{@"set":setblock,@"touch":touchblock}];
    }
    if(coulddim){
        
        
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){

            [cell.avatarImageView setImage:[UIImage imageNamed:@"sessiondim"]];
            [cell.avatarImageView setTintColor:[UIColor lightGrayColor]];
            cell.groupNameLabel.text = @"";

        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            DelGroupMemberViewController* vc = [[DelGroupMemberViewController alloc]initWithGroup:gentity];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            return ;
        };
        [_others addObject:@{@"set":setblock,@"touch":touchblock}];
    }
    

    NSInteger n = (self.view.frame.size.width-5)/69;
    NSInteger h;
    if(n!=0){
        h = _others.count/n + ((_others.count%n)>0?1:0) ;
    }
    else h =1;
    CGFloat height = MAX(104, h*84+20+(h-1)*10);
    
    CGRect frame = _headerView.frame;
    frame.size.height = height;
    _headerView.frame = frame;
    self.tableView.tableHeaderView = _headerView;
}

-(void)onGroupUpdate:(NSNotification*)notify{
    NSString* gid = [notify.object objectAtIndex:0];
    GroupNotifyType type = [[notify.object objectAtIndex:1] integerValue];
    
    if([gid isEqualToString:_sentity.sessionID] ){
        if(type & GROUP_NOTIFY_MEMBER){
            [self initMemberDataModel];
            [_memberAvatarsView reloadData];
        }
        if(type & GROUP_NOTIFY_OTHER){
            [self initGroupData];
        }
    }
    
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    if(object != _memberAvatarsView) return;

    CGFloat size = MAX(104, _memberAvatarsView.contentSize.height+10);
    
  //  return;
   
    if(_headerView.frame.size.height != size){
        
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _headerView.frame;
            frame.size.height = size;
            _headerView.frame = frame;
            self.tableView.tableHeaderView = _headerView;
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [[_dataModel[indexPath.row] objectForKey:@"h"] floatValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [_dataModel[indexPath.row] objectForKey:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Action actionblock = [_dataModel[indexPath.row] objectForKey:@"action"];
    
    if(actionblock) actionblock();
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _others.count;
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString* CELL_ID = @"AvatarNickCell";
    if(!_coreg){
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
        _coreg = YES;
    }
    AvatarNickCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    SetUniverseBlock block =  (SetUniverseBlock)[_others[indexPath.row]objectForKey:@"set"];
    [cell.avatarImageView makeBorder];
    block(cell);
    //[cell setUserID:TheRuntime.user.objID WithGroup:nil];
    
    return cell;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TouchUniverseBlock block =  [_others[indexPath.row] objectForKey:@"touch"];
    block(nil);
}


#pragma mark action
-(void)onDND:(id)sender{
    UIButton *dndBtn = sender;
    dndBtn.selected = !dndBtn.selected;
    [_sentity SessionDND:dndBtn.isSelected?1:0];
}
-(void)onTop:(id)sender{
    UIButton *dndBtn = sender;
    dndBtn.selected = !dndBtn.selected;
    [[SessionModule sharedInstance]topSession:_sentity Top:dndBtn.isSelected];
}
-(void)onShowNick:(id)sender{
    UIButton *dndBtn = sender;
    dndBtn.selected = !dndBtn.selected;
    [_sentity SessionShowNick:dndBtn.isSelected?1:0];
}

-(void)onsaveContact:(id)sender{
    UIButton *contactBtn =sender;
    contactBtn.selected = !contactBtn.selected;
    if(contactBtn.isSelected){
        [[ContactModule shareInstance]addGroupToContact:_sentity.sessionID Block:^(NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
            }
            
        }];
    }
    else{
        [[ContactModule shareInstance]removeGroupFromContact:_sentity.sessionID Block:^(NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
            }        }];
    }
}
-(void)onQuitGroup{
    [SVProgressHUD showSuccessWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[DDGroupModule instance]quitGroup:_sentity.sessionID Block:^(NSError * error, id respone) {
        if(!error){
            [SVProgressHUD showSuccessWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error:%@,code:%ld",error.domain,error.code] maskType:SVProgressHUDMaskTypeBlack];
        }
    }];
}
- (void)sendMessageBtnClick {
    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestOpenSession object:nil userInfo:nil];
    
    ChatViewController *sessionVC = [ChatViewController initWithUserID:_sentity.sessionID];
    [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],sessionVC] animated:YES];
}
- (void)deleFirend {
    //dele....
}
@end
