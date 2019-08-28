//
//  SubscribeCheckHistoryVC.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "SubscribeCheckHistoryVC.h"
#import <Masonry.h>
#import "SessionEntity.h"
#import "MessageDataModel.h"
#import "ChatCell.h"
#import "SessionModule.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import "SubscribeModule.h"
#import "HyperLinkVC.h"
#import "DDUserModule.h"
#import "ResourceVCViewController.h"
#import "MessageSendModule.h"
@interface SubscribeCheckHistoryVC ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SessionEntity *sentity;
@property (assign, nonatomic) BOOL reg;
@property (nonatomic, strong) MessageDataModel *dataModel;
@property (assign, nonatomic) int pullState;
@end

#define NUM_CELL _dataModel.count

#define MADJ_LOG(msg) NSLog(@"%@,%s,%d",msg,__FUNCTION__,__LINE__)
static const int PULL_IDLE = 1;
static const int PULL_ING  = 2;
@implementation SubscribeCheckHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];

}

-(id)init{
    self = [super init];
    self.view.backgroundColor = [UIColor whiteColor];
    
  
    
    [self awakeFromNib];
    _reg = NO;
    
    _pullState = PULL_IDLE;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onAvatap:) name:SubNotify_AvatarTap object:nil];
    
    return self;
}

-(void)awakeFromNib{
    //_tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _tableView.backgroundView = [[UIView alloc]init];
    _tableView.backgroundView.backgroundColor = [UIColor whiteColor];
    [_tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionPrior context:nil];
}

-(void)dealloc{
    [_tableView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatBaseCell* cell = obj;
        [cell willDisappare];
    }];
    
    [[SessionModule sharedInstance]setSessionOpened:_sentity.sessionID Opened:NO];
}

-(void)setSession:(SessionEntity *)sentity{
    assert(_sentity == nil);
    
    _sentity = sentity;
    if(sentity.sessionType == SessionTypeSessionTypeSingle){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userUpdate:) name:DDNotificationUserUpdated object:nil];
        [self userUpdateImpl:_sentity.sessionID];
        
        [[ContactModule shareInstance]getUserInfoWithNotification:sentity.sessionID ForUpdate:YES];
    }
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(groupUpdate:) name:DDNotificationGroupUpdated object:nil];
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:_sentity.sessionID Forupdate:YES];
        
        [self groupUpdateImpl:_sentity.sessionID];
       
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:sentity.sessionID Forupdate:YES];
    }
    if(sentity.sessionType == SessionTypeSessionTypeSubscription){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
        [[SubscribeModule shareInstance]getSBInfoWithNotification:_sentity.sessionID ForUpdate:YES];
    }
    _dataModel = [[MessageDataModel alloc]initWithSession:sentity TableView:_tableView InitialMessageCount:20 PullMessageCount:20];
    
    [[SessionModule sharedInstance]setSessionOpened:sentity.sessionID Opened:YES];
    [[SessionModule sharedInstance]setSessionRead:sentity   ];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSessionUpdate:) name:DDNotificationSessionUpdated object:nil];
    
}
-(void)onSessionUpdate:(NSNotification*)notify{
    if(notify.object == _sentity){
        [_tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatBaseCell* cell = (ChatBaseCell*)obj;
            [cell setSessionEntity:notify.object];
        }];
    }
}
-(void)userUpdate:(NSNotification*)notify{
    NSString* uid = notify.object;
    if([uid isEqualToString:_sentity.sessionID]){
        [self userUpdateImpl:uid];
    }
}
-(void)userUpdateImpl:(NSString*) uid{
    DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:uid];
    ContactInfoEntity* centity = [[ContactModule shareInstance]GetContactInfoByID:uid];
    NSString* text = nil;
    if(uentity){
        text = uentity.nick;
    }
    if(centity && [centity hasRmkname]){
        text = centity.rmkname;
    }
}
-(void)groupUpdate:(NSNotification*)notify{
    NSString* gid = [notify.object objectAtIndex:0];
    GroupNotifyType type = [[notify.object objectAtIndex:1] integerValue];
    if(type & GROUP_NOTIFY_MEMBER && [gid isEqualToString:_sentity.sessionID]){
        [self groupUpdateImpl:gid];
    }
}
-(void)groupUpdateImpl:(NSString*)gid{
    GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:gid];
    if(!gentity) return;
    __block BOOL ingroup = NO;
    
    [gentity.groupUserIds enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isEqualToString:TheRuntime.user.objID]){
            ingroup = YES;
            *stop = YES;
        }
    }];
    if(!ingroup){
        self.navigationItem.rightBarButtonItem = nil;
    }
}
-(void)subscribeUpdate:(NSNotification*)notify{
    NSString* sbuuid = notify.object[0];
    if(![_sentity.sessionID isEqualToString:sbuuid]) return;
    SubscribeUpdateType type = [notify.object[1] integerValue];
    
    if(type != SubscribeUpdateTypeInfo) return;
}
-(void)onHyperLink:(NSNotification*)notify{
    NSString* sid = notify.object[0];
    if(![sid isEqualToString:_sentity.sessionID]) return;
    NSString* hyperlink = notify.object[1];
    NSString* title     = notify.object[2];
    HyperLinkVC* vc = [[HyperLinkVC alloc]initWithHyperLink:hyperlink AndTitle:title];
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)onOpenFile:(NSNotification*)notify {
    NSString* filename = notify.object[0];
    NSString* fileurl = notify.object[1];
    NSString* filetransurl = notify.object[2];
    NSString* ext = notify.object[3];
    ResourceVCViewController* vc = [[ResourceVCViewController alloc]initWithPath:fileurl ConverPath:filetransurl Type:ext Name:filename];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)onHtmlString:(NSNotification*)notify{
    NSString* htmlstr = notify.object[0];
    HyperLinkVC* vc = [[HyperLinkVC alloc]initWithHtmlStr:htmlstr];
    
    //   HtmlStringVC* vc = [[HtmlStringVC alloc]initWithHtmlStr:htmlstr];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark menu delegate

-(void)onMate:(NSDictionary *)mateDic{
    
    [[MessageSendModule shareInstance]makeSubscribeMessage:mateDic Session:_sentity Block:^(DDMessageEntity *msgentity) {
        
        
        if(msgentity) [_dataModel insertNewMessage:msgentity];
    }];
}
#pragma mark delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatBaseCell* basecell = (ChatBaseCell *)cell;
    cell.backgroundColor = [UIColor clearColor];
    DDMessageEntity* msgentity = [_dataModel messageAtInde:indexPath.row];
    
    [basecell setSessionEntity:_sentity];
    [basecell setMessageEntity:msgentity];
    
    [basecell setContentSize:[_dataModel SizeForMessageAtIndex:indexPath.row]];
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0){
    ChatBaseCell* basecell = (ChatBaseCell *)cell;
    [basecell willDisappare];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* prefix = [_dataModel chatPrefixWithIndex:indexPath.row];
    NSString* postfix = [_dataModel chatPostfixWithIndex:indexPath.row];
    
    
    NSString* CELL_ID = [NSString stringWithFormat:@"%@_%@",prefix,postfix];
    if(!_reg){
        
        UINib* nib = nil;
        
        nib = [UINib nibWithNibName:@"Text_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Text_left"];
        
        nib = [UINib nibWithNibName:@"Image_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Image_left"];
        
        nib = [UINib nibWithNibName:@"Video_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Video_left"];
        
        nib = [UINib nibWithNibName:@"File_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"File_left"];
        
        nib = [UINib nibWithNibName:@"Time_center" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Time_center"];
        
        nib = [UINib nibWithNibName:@"RichText_center" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"RichText_center"];
        
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [_dataModel SizeForMessageAtIndex:indexPath.row].height;
    
    return height;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){
        if(textView.text.length > 0 ){
            DDMessageEntity* msgentity = [[MessageSendModule shareInstance]sendTextMessage:textView.text Session:_sentity];
            
            if(msgentity) [_dataModel insertNewMessage:msgentity  ];
        }
        return NO;
    }
    
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if(scrollView.contentOffset.y < -104 && scrollView.isTracking == NO
       && _pullState == PULL_IDLE && [_dataModel canPulling]){
        _pullState = PULL_ING;
        //_tableView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
            [scrollView setContentOffset:CGPointMake(0, -104) animated:NO ];
            [_tableView.backgroundView layoutIfNeeded];
        } completion:^(BOOL finished) {
            CGFloat height = scrollView.contentOffset.y;
            
            [_dataModel pullMessage:^(CGFloat msgheight,NSInteger dim) {
                if(dim == 0){
                    _tableView.userInteractionEnabled = YES;
                    return ;
                }
                CGFloat nheight = height+msgheight;
                
                
                [scrollView setContentOffset:CGPointMake(0, nheight) animated:NO];
                
            }];
        }];
        }
    else{
    }
    
    if(scrollView.contentOffset.y <= -scrollView.contentInset.top){
        [_dataModel setAutoToButton:NO];
    }
    if(scrollView.contentOffset.y >= scrollView.contentSize.height-scrollView.frame.size.height){
        [_dataModel setAutoToButton:YES];
    }
}

@end
