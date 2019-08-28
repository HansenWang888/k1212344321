#import "modifygroupmemberviewcontroller.h"
#import "ContactDataModel.h"
#import "ModifyGroupCell.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "ChatVIewController.h"
#import "SessionEntity.h"
#import "GroupEntity.h"
#import "DDUserEntity.h"
#import "DDUserModule.h"
#import "DDGroupModule.h"
#import "ContactModule.h"
@interface AvatarCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;

-(void)setUid:(NSString*)uid;
@end

@implementation AvatarCell
-(void)setUid:(NSString*)uid{
    [_avatarImageView setUid:uid];
}

@end

@implementation ModifyGroupMemberViewController
{
    NSString* _gid;
    
    UICollectionView* _collectionView;
    UITableView*      _tableView;
    BOOL              _reg;
    BOOL              _treg;
    ContactDataModel* _dataModel;
    NSInteger         _lestSelect;
    NSMutableArray<ContactUserAbstract*>*   _collectionDataModel;
    
}
-(NSInteger)FindAbs:(NSString*)uid{
    NSInteger ret = -1;
    for(NSInteger i =  0 ; i < _collectionDataModel.count ; ++i){
        if([_collectionDataModel[i].uid isEqualToString:uid]) return i;
    }
    return ret;
}
-(void)dealloc{
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    NSInteger n = _collectionView.contentSize.height/54;
    CGFloat frameheight = 64;
    if(n==0 || n == 1) frameheight = 64;
    else{
        frameheight = _collectionView.contentSize.height+10;
    }
    if(frameheight == _collectionView.frame.size.height) return;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = _collectionView.frame;
        frame.size.height = frameheight;
        _collectionView.frame = frame;
        
        CGFloat ypos = _collectionView.frame.size.height + _collectionView.frame.origin.y;
        _tableView.frame = CGRectMake(0, ypos, self.view.frame.size.width, self.view.frame.size.height-ypos);
    }];
    
    
}
-(void)initCollectionView{
    _reg = NO;
    UIView* view = [[UIView alloc]init];
    [self.view addSubview:view];
    UICollectionViewFlowLayout* flowlayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowlayout.itemSize = CGSizeMake(44, 44);
    flowlayout.headerReferenceSize = CGSizeZero;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64) collectionViewLayout:flowlayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
}
-(void)initTableView{
    _treg = NO;
    _tableView = [[UITableView alloc]init];
    //    CGFloat ypos = _collectionView.frame.size.height + _collectionView.frame.origin.y;
    //    _tableView.frame = CGRectMake(0, ypos, self.view.frame.size.width, self.view.frame.size.height-ypos);
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(_collectionView.mas_bottom);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}
-(void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionDataModel = [NSMutableArray new];
    [self initCollectionView];
    [self initTableView];
    _lestSelect = 1;
    
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:IMLocalizedString(@"完成", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(id)init{
    self = [super init];
    [self initView];
    self.title = IMLocalizedString(@"新建会话组", nil);
    _lestSelect = 2;
    _dataModel = [[ContactDataModel alloc]initWithTableView:_tableView SectionStart:0];
    [_dataModel reload];
    return self;
}
-(id)initWithSession:(SessionEntity*)sentity{
    self = [super init];
    [self initView];
    
    NSMutableArray* exclude = [NSMutableArray new];
    if(sentity.sessionType == SessionTypeSessionTypeSingle){
        [exclude addObject:sentity.sessionID];
    }
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:sentity.sessionID];
        assert(gentity);
        [gentity.groupUserIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [exclude addObject:obj];
        }];
        _gid = sentity.sessionID;
    }
    
    _dataModel = [[ContactDataModel alloc]initWithTableView:_tableView SectionStart:0 Excludes:exclude];
    [_dataModel reload];
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _collectionDataModel.count;
}

#pragma mark collection delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CELL_ID = @"AvatarCollectionCell";
    if(!_reg){
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
        _reg = YES;
    }
    AvatarCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    [cell setUid: _collectionDataModel[indexPath.row].uid];
    
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}


#pragma mark tableviewdelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataModel LetterCount];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger rownum = [_dataModel UserAbstractsForSection:section].count;
    return rownum;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CELL_ID = @"ModifyGroupCell";
    if(_treg == NO){
        
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
        
        _treg = YES;
    }
    
    ModifyGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    ContactUserAbstract* userabs = [_dataModel UserAbstractForIndexPath:indexPath];
    cell.userAbstrct = userabs;
    
    cell.Checked = [self FindAbs:userabs.uid] !=-1;
    return cell;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
    return  [_dataModel FLForSection:section];
    
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [_dataModel Letters];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return index;
}


#pragma mark TABLE_VIEW_DELEGET

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ModifyGroupCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL checked = cell.Checked;
    [cell setChecked:!checked];
    
    
    if(checked){
        NSInteger index = [self FindAbs:cell.userAbstrct.uid];
        assert(index != -1);
        [_collectionDataModel removeObjectAtIndex:index];
        NSIndexPath* delindexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[delindexpath]];
        
    }
    else{
        NSIndexPath* insindexpath = [NSIndexPath indexPathForRow:_collectionDataModel.count inSection:0];
        [_collectionDataModel addObject:cell.userAbstrct];
        [_collectionView insertItemsAtIndexPaths:@[insindexpath]];
        
    }
    [self onSelect];
}

#pragma mark action
-(void)onSelect{
    if(_collectionDataModel.count != 0){
        [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"%@(%ld)", IMLocalizedString(@"完成", nil), _collectionDataModel.count]];
    }
    else{
        [self.navigationItem.rightBarButtonItem setTitle:IMLocalizedString(@"完成", nil)];
    }
    if(_collectionDataModel.count < _lestSelect){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
}
-(void)onDone{
    if(_gid == nil){
        __block NSString* name = @"";
        [_collectionDataModel enumerateObjectsUsingBlock:^(ContactUserAbstract * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.nick isEqualToString:@""]) return ;
            NSString* str = nil;
            if(idx == 0) str = [name stringByAppendingFormat:@"%@",obj.nick];
            else  str = [name stringByAppendingFormat:@",%@",obj.nick];
            if(str.length >16) {
                //name = [name stringByAppendingString:@" 等"];
                *stop = YES;
            }
            else{
                name = str;
            }
        }];
        
        NSMutableArray* uids = [NSMutableArray new];
        [_dataModel.excludes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [uids addObject:obj];
        }];
        [_collectionDataModel enumerateObjectsUsingBlock:^(ContactUserAbstract * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [uids addObject:obj.uid];
        }];
        
        [SVProgressHUD showWithStatus:IMLocalizedString(@"正在创建", nil) maskType:SVProgressHUDMaskTypeGradient];
        [[DDGroupModule instance]CreateGroup:uids GroupName:name Block:^(NSError * error, GroupEntity *group) {
            if(!error){
                [SVProgressHUD showSuccessWithStatus:IMLocalizedString(@"创建成功", nil)];
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestOpenSession object:nil userInfo:nil];
                
                UIViewController* sessionVC = [ChatViewController initWithGroupID:group.objID];
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],sessionVC] animated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error:%@,code:%ld",error.domain,error.code]];
            }
        }];
    }
    else{
        [self addUserToGroup];
    }
}
-(void)addUserToGroup{
    NSMutableArray* uids = [NSMutableArray new];
    [_collectionDataModel enumerateObjectsUsingBlock:^(ContactUserAbstract * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids addObject:obj.uid];
    }];
    
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeGradient];
    [[DDGroupModule instance]addMemberToGroup:uids GroupID:_gid Block:^(NSError * error, id respone) {
        if(!error){
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error:%@,code:%ld",error.domain,error.code]];
        }
    }];
}
@end

@interface ContactUserAbstract(GroupUserAbstract)

-(id)initWithUserID:(NSString*)uid GroupEntity:(GroupEntity*)gentity;

@end

@implementation ContactUserAbstract(GroupUserAbstract)

-(id)initWithUserID:(NSString*)uid GroupEntity:(GroupEntity*)gentity{
    DDUserEntity* user = [[DDUserModule shareInstance]getUserByID:uid];
    ContactInfoEntity* cinfo = [[ContactModule shareInstance]GetContactInfoByID:uid];
    
    self.uid = uid;
    
    if(user != nil){
        self.nick = user.nick;
        self.avatar = user.avatar;
    }
    else{
        self.nick = @"";
        self.avatar = @"";
    }
    
    if(cinfo && [cinfo hasRmkname]) self.nick = cinfo.rmkname;
    
    NSString* gnick = [gentity getGroupNick:uid];
    if(gnick && ![gnick isEqualToString:@""]) self.nick = gnick;
    
    return self;
}

@end

@implementation DelGroupMemberViewController
{
    GroupEntity* _gentity;
    UICollectionView* _collectionView;
    UITableView*      _tableView;
    BOOL              _reg;
    BOOL              _treg;
    NSMutableArray<ContactUserAbstract*>*   _dataModel;
    NSMutableArray*   _collectionDataModel;
    NSInteger         _lestSelect;
}
-(void)initCollectionView{
    _reg = NO;
    UIView* view = [[UIView alloc]init];
    [self.view addSubview:view];
    UICollectionViewFlowLayout* flowlayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowlayout.itemSize = CGSizeMake(44, 44);
    flowlayout.headerReferenceSize = CGSizeZero;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64) collectionViewLayout:flowlayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
}
-(void)initTableView{
    _treg = NO;
    _tableView = [[UITableView alloc]init];
    //    CGFloat ypos = _collectionView.frame.size.height + _collectionView.frame.origin.y;
    //    _tableView.frame = CGRectMake(0, ypos, self.view.frame.size.width, self.view.frame.size.height-ypos);
    
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 1)];
    _tableView.tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(_collectionView.mas_bottom);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionDataModel = [NSMutableArray new];
    [self initCollectionView];
    [self initTableView];
    _lestSelect = 1;
    
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:IMLocalizedString(@"删除", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(void)dealloc{
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
}
-(id)initWithGroup:(GroupEntity *)gentity{
    self = [super init];
    _gentity = gentity;
    [self initView];
    _dataModel = [NSMutableArray new];
    [gentity.groupUserIds enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isEqualToString:TheRuntime.user.objID]) return ;
        
        ContactUserAbstract* abs = [[ContactUserAbstract alloc]initWithUserID:obj GroupEntity:gentity];
        [_dataModel addObject:abs];
    }];
    
    _collectionDataModel = [NSMutableArray new];
    
    return self;
}


#pragma mark delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _collectionDataModel.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CELL_ID = @"AvatarCollectionCell";
    if(!_reg){
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
        _reg = YES;
    }
    AvatarCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    [cell setUid: _collectionDataModel[indexPath.row]];
    
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}


#pragma mark tableviewdelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CELL_ID = @"ModifyGroupCell";
    if(_treg == NO){
        
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
        
        _treg = YES;
    }
    
    ModifyGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    ContactUserAbstract* userabs = [_dataModel objectAtIndex:indexPath.row];
    cell.userAbstrct = userabs;
    
    return cell;
}


#pragma mark TABLE_VIEW_DELEGET

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ModifyGroupCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL checked = cell.Checked;
    [cell setChecked:!checked];
    
    
    if(checked){
        NSInteger index = [_collectionDataModel indexOfObject:  cell.userAbstrct.uid];
        
        [_collectionDataModel removeObjectAtIndex:index];
        NSIndexPath* delindexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[delindexpath]];
        
    }
    else{
        NSIndexPath* insindexpath = [NSIndexPath indexPathForRow:_collectionDataModel.count inSection:0];
        [_collectionDataModel addObject:cell.userAbstrct.uid];
        [_collectionView insertItemsAtIndexPaths:@[insindexpath]];
        
    }
    [self onSelect];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    NSInteger n = _collectionView.contentSize.height/54;
    CGFloat frameheight = 64;
    if(n==0 || n == 1) frameheight = 64;
    else{
        frameheight = _collectionView.contentSize.height+10;
    }
    if(frameheight == _collectionView.frame.size.height) return;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = _collectionView.frame;
        frame.size.height = frameheight;
        _collectionView.frame = frame;
        
        CGFloat ypos = _collectionView.frame.size.height + _collectionView.frame.origin.y;
        _tableView.frame = CGRectMake(0, ypos, self.view.frame.size.width, self.view.frame.size.height-ypos);
    }];
    
    
}

-(void)onSelect{
    if(_collectionDataModel.count != 0){
        [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"%@(%ld)", IMLocalizedString(@"删除", nil), _collectionDataModel.count]];
    }
    else{
        [self.navigationItem.rightBarButtonItem setTitle:IMLocalizedString(@"删除", nil)];
    }
    if(_collectionDataModel.count < _lestSelect){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
}
-(void)onDone{
    
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeGradient];
    [[DDGroupModule instance]delMemberFromGroup:_collectionDataModel GroupID:_gentity.objID Block:^(NSError * error, id respone) {
        if(!error){
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error:%@,code:%ld",error.domain,error.code]];
        }
    }];
}
@end





