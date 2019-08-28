
#import "SessionTableView.h"
#import "SessionModule.h"
#import "sessionCell.h"
#import "SessionEntity.h"
#import "DDGroupModule.h"
#import "subcribeCell.h"
#import "nameLabel.h"
#import "avatarImageView.h"
#import "ViewSetUniversal.h"
@interface SessionDataModel : NSObject

-(void)reload;
//return -1 if not in array
-(void)removeSessionEntityAtIndex:(NSInteger)index;
-(NSInteger)count;
-(NSInteger)getSessionIndex:(SessionEntity*)sid;
-(SessionEntity*)SessionEntityAtIndex:(NSInteger)index;
-(id)initWithTableView:(UITableView*)tableView SessionTableViewType:(SessionTableViewType)sessionTableViewType;
@end

@implementation SessionDataModel
{
    NSMutableArray<SessionEntity*>* _datas;
    UITableView* _tableView;
    SessionTableViewType  _tableViewType;
   
}
-(NSInteger)count{
    return _datas.count;
}
-(id)initWithTableView:(UITableView*)tableView SessionTableViewType:(SessionTableViewType)sessionTableViewType{
    self = [super init];
    _tableViewType = sessionTableViewType;
    _tableView = tableView;
    _datas = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newSession:) name:DDNotificationSessionCreated object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionUpdate:) name:DDNotificationSessionUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSession:) name:DDNotificationSessionRemove object:nil];
    
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)removeSession:(NSNotification*)notification{
    
    NSInteger index = [self getSessionIndex:notification.object];
    if(index == NSNotFound){
        
    }
    else{
        [self removeSessionEntityAtIndex:index];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(void)newSession:(NSNotification*) notification {
    SessionEntity* sentity = notification.object;
    
    
    if([self getSessionIndex:sentity] != NSNotFound) return;
    if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry){
        if(sentity.sessionType == SessionTypeSessionTypeSubscription) return;
    }
    else if(_tableViewType == SessionTableViewTypeSubscribe){
        if(sentity.sessionType != SessionTypeSessionTypeSubscription) return;
    }
    
    NSInteger sit = [self getSessionSit:sentity];
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:sit inSection:0];
    [_datas insertObject:sentity atIndex:sit];
    
    [_tableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)sessionUpdate:(NSNotification*) notification{
    
    SessionEntity* sentity = notification.object;
    NSInteger index = [self getSessionIndex:sentity];
    if(index == NSNotFound) return;
    [_datas replaceObjectAtIndex:index withObject:sentity];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    [_datas removeObject:sentity];
    NSInteger nindex = [self getSessionSit:sentity];
    [_datas insertObject:sentity atIndex:nindex];
    if(nindex != index){
        [_tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toIndexPath:[NSIndexPath indexPathForRow:nindex inSection:0]];
    }
}
-(void)reload{
    [_datas removeAllObjects];
    [[[SessionModule sharedInstance]getAllSessions] enumerateObjectsUsingBlock:^(SessionEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger sit = [self getSessionSit:obj];
        
        if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry){
            if (!(obj.sessionType == SessionTypeSessionTypeSubscription)) {
                [_datas insertObject:obj atIndex:sit];
            }
        }
        else if(_tableViewType == SessionTableViewTypeSubscribe){
            if (obj.sessionType == SessionTypeSessionTypeSubscription) {
                [_datas insertObject:obj atIndex:sit];
            }
        }

    }];
}
//return NSNotFound if not in array
-(NSInteger)getSessionIndex:(SessionEntity*)sentity{
    return [_datas indexOfObject:sentity];
}
//never nsnot found
-(BOOL)highlevel:(SessionEntity*)first With:(SessionEntity*)second{
    
    if(first.topLevel > second.topLevel) return YES;
    if(first.topLevel < second.topLevel) return NO;
    return first.timeInterval>=second.timeInterval;
}
-(NSInteger)getSessionSit:(SessionEntity*)sentity{
    NSInteger ret = _datas.count;
    for(NSInteger i = 0 ; i < _datas.count ; ++i){
        if([self highlevel:sentity With:_datas[i]]){
            return i;
        }
    }
    return ret;
}
-(void)removeSessionEntityAtIndex:(NSInteger)index{
    assert(index<_datas.count);
    [_datas removeObjectAtIndex:index];
}
-(SessionEntity*)SessionEntityAtIndex:(NSInteger)index{
    assert(index<_datas.count);
    
    return _datas[index];
}

@end

@interface SessionTableView ()
@property (nonatomic, weak) UITableViewCell *lastCell;

@end
@implementation SessionTableView
{
    SessionDataModel* _dataModel;
    BOOL _reg;
    SessionTableViewType  _tableViewType;
    BOOL                  _needSubscribeAbstractCell;
}
- (void)awakeFromNib {
    
    [self initImpl];
}
- (void)initImpl {
    _reg = NO;
    
    self.tableFooterView = [[UIView alloc]init];
    self.delegate = self;
    self.dataSource = self;
    self.separatorInset = UIEdgeInsetsZero;
    
    _dataModel = [[SessionDataModel alloc]initWithTableView:self SessionTableViewType:_tableViewType];
    if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry){

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeAbstractUpdate) name:DDNotificationSubscribeAbstractUpdate object:nil];
    }
    
}
-(id)init{
    self = [super init];
    _tableViewType = SessionTableViewTypeUserAndGroupWithSubscribeEntry;
   
    [self initImpl];
    return self;
}
-(id)initWithSessionTableViewType:(SessionTableViewType)sessionTableViewType{
    self = [super init];
    _tableViewType = sessionTableViewType;
    [self initImpl];
    return self;
}
-(void)dealloc{
}

-(void)reloadData{
    
    [_dataModel reload];
    if([[SessionModule sharedInstance]hasSubscribeSession]){
        _needSubscribeAbstractCell = YES;
    }
    else{
        _needSubscribeAbstractCell = NO;
    }
    //需要排序
    [super reloadData];
}
-(void)subscribeAbstractUpdate{
    if([[SessionModule sharedInstance]hasSubscribeSession]){
        if(_needSubscribeAbstractCell == YES){
            [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataModel.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataModel.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        _needSubscribeAbstractCell = YES;
    }
    else{
        if(_needSubscribeAbstractCell == YES){
            [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataModel.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            
        }
        _needSubscribeAbstractCell = NO;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_tableViewType == SessionTableViewTypeSubscribe){
        return _dataModel.count;
    }
    else if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry){
       // NSLog(@"has subscribe:%ld",_needSubscribeAbstractCell);
       // return _dataModel.count+1;
        return _dataModel.count + ([[SessionModule sharedInstance] hasSubscribeSession]?1:0);
    }
    else{
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString* CELL_ID_SINGLE = @"SessionCellSingle";
    NSString* CELL_ID_GROUP  = @"SessionCellGroup";
    NSString* CELL_ID_SUBSCRIBE = @"SessionCellSubscribe";
    NSString* CELL_SUBSCRIBE = @"SubcribeCell";
    if(!_reg){
        UINib* nib_single = [UINib nibWithNibName:CELL_ID_SINGLE bundle:nil];
        [tableView registerNib:nib_single forCellReuseIdentifier:CELL_ID_SINGLE];
        UINib* nib_group = [UINib nibWithNibName:CELL_ID_GROUP bundle:nil];
        [tableView registerNib:nib_group forCellReuseIdentifier:CELL_ID_GROUP];
        UINib* nib_sb = [UINib nibWithNibName:CELL_ID_SUBSCRIBE bundle:nil];
        [tableView registerNib:nib_sb forCellReuseIdentifier:CELL_ID_SUBSCRIBE];
        
        UINib* nib_subcribe = [UINib nibWithNibName:CELL_SUBSCRIBE bundle:nil];
        [tableView registerNib:nib_subcribe forCellReuseIdentifier:CELL_SUBSCRIBE];
        _reg = YES;
    }
    if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry&&
       indexPath.row == _dataModel.count){
        SubcribeCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBSCRIBE forIndexPath:indexPath];
        cell.sessionNameLabel.text = IMLocalizedString(@"公众号", nil);
        [cell settelSubscribes];
        return cell;
    }
    SessionEntity* sentity = [_dataModel SessionEntityAtIndex:indexPath.row];
    SessionCell* cell = nil;
    if(sentity.sessionType == SessionTypeSessionTypeSingle){
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SINGLE  forIndexPath:indexPath ];
        
        [cell setSessionEntity:sentity];
    }
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_GROUP  ];
        [cell setSessionEntity:sentity];
    }
    if(sentity.sessionType == SessionTypeSessionTypeSubscription){
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SUBSCRIBE];
        [cell setSessionEntity:sentity];
    }
    assert(cell);
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry&&
       indexPath.row == _dataModel.count)){
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (!g_SplitVC.isClick) {
//        cell.selected = YES;
//        return;
//    }
//    if (cell == self.lastCell && (indexPath.row != _dataModel.count)) {
//        return;
//    }
//    self.lastCell = cell;
    if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry&&
       indexPath.row == _dataModel.count){
        if(_Sessiondelegate&&[_Sessiondelegate respondsToSelector:@selector(SubscribeSectionTouched)]){
            [_Sessiondelegate SubscribeSectionTouched];
        }
        return;
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_Sessiondelegate && [_Sessiondelegate respondsToSelector:@selector(SessionTouched:)]){
        [_Sessiondelegate SessionTouched:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){
    
    if(_tableViewType == SessionTableViewTypeUserAndGroupWithSubscribeEntry&&
       indexPath.row == _dataModel.count){
        return nil;
    }
    
    UITableViewRowAction* delaction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:IMLocalizedString(@"删除", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SessionEntity* sentity = [_dataModel SessionEntityAtIndex:indexPath.row];
        [[SessionModule sharedInstance]removeSessionByServer:sentity];
    }];
    
    
    return @[delaction];
}
@end
