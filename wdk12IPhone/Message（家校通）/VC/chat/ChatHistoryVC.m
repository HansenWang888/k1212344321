//
//  ChatHistoryVC.m
//  wdk12pad-HD-T
//
//  Created by macapp on 16/4/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ChatHistoryVC.h"
#import "MessageNetWorkDataModel.h"
#import "ChatTimeDimCell.h"
#import "mjrefresh.h"
#import "SessionEntity.h"
#import "HyperLinkVC.h"
#import "ResourceVCViewController.h"
@interface ChatHistoryVC ()

@end

@implementation ChatHistoryVC
{
    MessageNetWorkDataModel* _dataModel;
    
 //   SessionEntity* _sentity;
    NSString* _sbid;
    BOOL           _reg;
}
-(id)initWithSubscribeID:(NSString*)sbid{
    self = [super initWithStyle:UITableViewStylePlain];
    _sbid = sbid;
    _dataModel = [[MessageNetWorkDataModel alloc]initWithSubscribeID:_sbid TableView:self.tableView InitialMessageCount:10 PullMessageCount:10];

    
    [self.tableView setMj_footer:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [_dataModel pullMessage:YES Block:^(BOOL canpull) {
            
            if(canpull == NO){
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            else{
                [self.tableView.mj_footer endRefreshing];
            }
        }];
    }]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onHyperLink:) name:DDNotificationReqeustHyperLink object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOpenFile:) name:DDNotificationRequestOpenFile object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onHtmlString:) name:DDNotificationRequestHtmlString object:nil];
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = IMLocalizedString(@"历史消息", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)onHyperLink:(NSNotification*)notify{
    NSString* sid = notify.object[0];
    if(![sid isEqualToString:_sbid]) return;
  
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
   
    NSString* htmlstr = notify.object[@"content"];
    HyperLinkVC* vc = [[HyperLinkVC alloc]initWithHtmlStr:htmlstr];
    vc.title = notify.object[@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatBaseCell* basecell = (ChatBaseCell *)cell;
    cell.backgroundColor = [UIColor clearColor];
    DDMessageEntity* msgentity = [_dataModel messageAtInde:indexPath.row];
    
    [basecell setSessionID:_sbid];
 //   [basecell setSessionEntity:_sentity];
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
        nib = [UINib nibWithNibName:@"Text_right" bundle:nil];
        
        [tableView registerNib:nib forCellReuseIdentifier:@"Text_right"];
        
        nib = [UINib nibWithNibName:@"Text_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Text_left"];
        nib = [UINib nibWithNibName:@"Voice_right" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Voice_right"];
        nib = [UINib nibWithNibName:@"Voice_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Voice_left"];
        nib = [UINib nibWithNibName:@"Image_right" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Image_right"];
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
        
        [tableView registerNib:[UINib nibWithNibName:@"Invite_left" bundle:nil] forCellReuseIdentifier:@"Invite_left"];
        [tableView registerNib:[UINib nibWithNibName:@"Invite_right" bundle:nil] forCellReuseIdentifier:@"Invite_right"];
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [_dataModel SizeForMessageAtIndex:indexPath.row].height;
    
    return height;
}


@end
