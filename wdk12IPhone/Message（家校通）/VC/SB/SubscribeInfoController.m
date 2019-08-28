//
//  SubscribeInfoController.m
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeInfoController.h"
#import "SubscribeEntity.h"
#import "SubscribeModule.h"
#import "UIImageView+WebCache.h"
#import "ChatVIewController.h"
#import "WDDescView.h"
#import <Masonry.h>
#import "avatarImageView.h"
#import "ViewSetUniversal.h"
#import "RecommendSubscribeVC.h"
#import "SubscribeListVC.h"
#import "SubscribeModule.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "ChatHistoryVC.h"
@interface SubscribeHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgaeView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;


@end
@implementation SubscribeHeader



@end

@interface SubscribeInfoController ()

@property (nonatomic, strong) UIButton *setEmptyBtn;//清空内容按钮
@property (nonatomic, strong) UIButton *cancleBtn;//取消关注按钮
@property (nonatomic, strong) UIButton *recommendBtn;//推荐按钮
@property (nonatomic, strong) SessionEntity *sentity;


@end
@implementation SubscribeInfoController{
    NSString* _sbid;
    SubscribeEntity* _sbentity;
    NSMutableArray<NSDictionary*>* _dataModel;
    
    WDDescView *_descView;
    UITableViewCell* _introduceCell;
    UITableViewCell *_hostTypeCell;//主体类型
    UITableViewCell *_acceptMessageCell;
    UITableViewCell *_hostryCell;
    UIButton*        _footerBtn;
}
-(id)initWithSBID:(NSString*)sbid {
    self = [super initWithStyle:UITableViewStylePlain];
    _sbid = sbid;
    _sbentity = [[SubscribeModule shareInstance]getSubscribeBySBID:_sbid];
    self.title = _sbentity.name;
    _sentity = [[SessionModule sharedInstance] getSessionById:sbid];
    [self initView];
    if(_sbentity) [self updateSB];
    [[SubscribeModule shareInstance]getSBInfoWithNotification:_sbid ForUpdate:YES ];
    return self;
}
//判断公众号列表是否包含当前通讯录
- (BOOL)isContainsSubContact {
    for (SubscribeAttentionEntity *entity in [[SubscribeModule shareInstance] getSubs]) {
        if ([entity.objID isEqualToString:_sbentity.objID]) {
            return YES;
        }
    }
    return NO;
}
-(void)viewDidLoad{
    self.view.backgroundColor = COLOR_Creat(249, 249, 249, 1);
}
-(void)initView{
    _dataModel = [NSMutableArray new];
    _descView = [WDDescView descView];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 180)];
    [self.tableView.tableHeaderView addSubview:_descView];
    [_descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.right.bottom.offset(0);
    }];
    _descView.backgroundColor = [UIColor clearColor];
    
    _hostTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hostTypeCell"];
    _hostTypeCell.textLabel.text = IMLocalizedString(@"主体类型", nil);
    [_dataModel addObject:@{@"cell":_hostTypeCell}];


    _introduceCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"introduce"];
    _introduceCell.detailTextLabel.textAlignment = NSTextAlignmentLeft;

    _introduceCell.textLabel.text = IMLocalizedString(@"说明", nil);
    [_dataModel addObject:@{@"cell":_introduceCell}];
    _acceptMessageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"acceptMessageCell"];

    [self setupOtherCell];
    _hostryCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hostryCell"];
    _hostryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [_dataModel addObject:@{@"cell":_hostryCell}];
    _hostryCell.textLabel.text = IMLocalizedString(@"查看历史消息", nil);
   
    _footerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _setEmptyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _setEmptyBtn.backgroundColor = COLOR_Creat(153, 153, 153, 1);
    _recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recommendBtn.titleLabel.numberOfLines = 0;
    [ViewSetUniversal setButton:_recommendBtn title:[NSString stringWithFormat:@" \U0000e61b \n %@ ", IMLocalizedString(@"推荐", nil)] fontSize:16 textColor:[UIColor grayColor] fontName:@"iconfont" action:@selector(recommendBtnClick) target:self];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:@"\U0000e67e"];
    [attribute setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"iconfont" size:30],NSForegroundColorAttributeName : COLOR_Creat(94, 191, 109, 1)} range:NSMakeRange(0, attribute.mutableString.length)];
    NSMutableAttributedString *attribute2 = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n%@", IMLocalizedString(@"推荐", nil)]];
    [attribute2 setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, attribute2.mutableString.length)];
    [attribute insertAttributedString:attribute2 atIndex:1];
    [_recommendBtn setAttributedTitle:attribute forState:UIControlStateNormal];
     [ViewSetUniversal setButton:_cancleBtn title:[NSString stringWithFormat:@"\U0000e65a %@", IMLocalizedString(@"取消关注", nil)] fontSize:12 textColor:nil fontName:@"iconfont" action:@selector(cancleAttentionResponde) target:self];
    [ViewSetUniversal setButton:_setEmptyBtn title:[NSString stringWithFormat:@"\U0000e624 %@", IMLocalizedString(@"清空内容", nil)] fontSize:12 textColor:nil fontName:@"iconfont" action:@selector(mekeSubcribeEmpty) target:self];
    _cancleBtn.backgroundColor = COLOR_Creat(252, 102, 33, 1);
    _footerBtn.backgroundColor = COLOR_Creat(94, 191, 109, 1);
    [ViewSetUniversal setView:_footerBtn cornerRadius:3];
    [self.tableView.tableFooterView addSubview:_footerBtn];
    [self.tableView.tableFooterView addSubview:_cancleBtn];
    [self.tableView.tableFooterView addSubview:_setEmptyBtn];
    [self.tableView.tableFooterView addSubview:_recommendBtn];
    [self stepFooterView];
}
- (void)setupOtherCell {
    if ([self isContainsSubContact] && self.sentity != nil && ![_dataModel containsObject:@{@"cell":_acceptMessageCell}]) {
        UIButton *button = [[UIButton alloc] init];
        button.selected = _sentity.isShield;
        [ViewSetUniversal setButton:button title:@"\U0000e662" fontSize:30 textColor:[UIColor grayColor] fontName:@"iconfont" action:@selector(acceptMessageValueChange:) target:self];
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
        [button setTitle:@"\U0000e663" forState:UIControlStateSelected];
        _acceptMessageCell.textLabel.text = IMLocalizedString(@"免打扰", nil);
        _acceptMessageCell.accessoryView = button;
        
        [_dataModel addObject:@{@"cell":_acceptMessageCell}];
    }
}
- (void)stepFooterView {
    UIView* footview = self.tableView.tableFooterView;
    UIButton *sendBtn = _footerBtn;
    
    if ([self isContainsSubContact]) {
        [ViewSetUniversal setButton:sendBtn title:[NSString stringWithFormat:@"\U0000e62f %@", IMLocalizedString(@"进入公众号", nil)] fontSize:12 textColor:nil fontName:@"iconfont" action:@selector(goInSB) target:self];
       
        [ViewSetUniversal setView:_cancleBtn cornerRadius:3];
        _cancleBtn.hidden = NO;
        _setEmptyBtn.hidden = NO;
        _recommendBtn.hidden = NO;
        [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footview).offset(10);
            make.centerX.equalTo(footview.mas_centerX);
            make.width.equalTo(@80);
            make.height.equalTo(@35);
        }];
        [sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footview).offset(10);
            make.right.equalTo(_cancleBtn.mas_left).offset(-20);
            make.width.equalTo(@80);
            make.height.equalTo(@35);
        }];
        [_setEmptyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footview).offset(10);
            make.left.equalTo(_cancleBtn.mas_right).offset(20);
            make.width.equalTo(@80);
            make.height.equalTo(@35);
        }];
        [_recommendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_cancleBtn.mas_bottom).offset(20);
            make.centerX.equalTo(_cancleBtn);
        }];
    } else {
        _cancleBtn.hidden = YES;
        _setEmptyBtn.hidden = YES;
        _recommendBtn.hidden = YES;
        [ViewSetUniversal setButton:sendBtn title:[NSString stringWithFormat:@"\U0000e625 %@", IMLocalizedString(@"关注公众号", nil)] fontSize:12 textColor:nil fontName:@"iconfont" action:@selector(onAttention) target:self];
        [sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footview);
            make.top.equalTo(footview).offset(10);
            make.width.equalTo(@(footview.bounds.size.width * 0.5));
            make.height.equalTo(@35);
        }];
    
    }
}
- (void)recommendBtnClick {
    //推荐公众号
    RecommendSubscribeVC *vc = [RecommendSubscribeVC new];
    vc.subscribeID = _sbid;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)mekeSubcribeEmpty {
    //清空公众号内容
    SessionEntity* sentity = [[SessionModule sharedInstance]getSessionById:_sbid];
    if(sentity){
        [SVProgressHUD showSuccessWithStatus:nil];
        [[SubscribeModule shareInstance] clearLocalMessage:_sbid];
        [[SessionModule sharedInstance]clearSession:sentity];
        ChatViewController *vc = [ChatViewController initWithSubscribeID:_sbid];
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],vc] animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
    }
}
- (void)cancleAttentionResponde {
    //取消关注,发送通知
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[SubscribeModule shareInstance]attentionSubscribe:_sbid Attention:SubscribeOptCancelsubscribe Block:^(NSError *error) {
        if(!error){
            [SVProgressHUD dismiss];
            //界面更新
            [weakSelf stepFooterView];
            if (self.sentity) {
                //如果存在会话就删除免打扰设置
                [_dataModel removeObjectAtIndex:3];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:0];
            }
            [weakSelf.navigationController popToViewController:weakSelf.navigationController.viewControllers[0] animated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error=%@",error.domain]];
        }
    }];
    
}
- (void)acceptMessageValueChange:(UIButton *)sender {
    sender.selected = !sender.selected;
    //接受消息....
    
    [_sentity SessionDND:sender.isSelected ? 1 : 0];
}
-(void)updateSB{
    _introduceCell.detailTextLabel.numberOfLines = 0;
    _introduceCell.detailTextLabel.text = _sbentity.introduce;

    _hostTypeCell.detailTextLabel.text = _sbentity.subject;
    [_descView.imageV sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(_sbentity.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    _descView.nameLabel.text = _sbentity.name;
    _descView.autographLabel.text = [NSString stringWithFormat:@"%@: %llu",IMLocalizedString(@"公众号", nil), [TheRuntime changeIDToOriginal:_sbentity.objID]];
    //添加免打扰
    [self setupOtherCell];
    if([[SubscribeModule shareInstance]getAttentionBySBID:_sbid] == nil){
        [self stepFooterView];
    }
    else{
        [self stepFooterView];
    }
}
#pragma mark action
-(void)onAttention{
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[SubscribeModule shareInstance]attentionSubscribe:_sbid Attention:SubscribeOptSubscribe Block:^(NSError *error) {
        if(!error){
            _sentity = [[SessionModule sharedInstance] getSessionById:_sbid];
            [SVProgressHUD showSuccessWithStatus:IMLocalizedString(@"关注成功", nil)];
            [self updateSB];
            if (_sentity) {
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataModel.count - 1 inSection:0]] withRowAnimation:0];
            }
            [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0]] animated:YES];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error=%@,code=%d",error.domain,error.code]];
        }
    }];
}
-(void)goInSB{
    ChatViewController* vc = [ChatViewController initWithSubscribeID:_sbid];
    NSArray *array = self.navigationController.viewControllers;
    [self.navigationController setViewControllers:@[array[0],vc] animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [_dataModel[indexPath.row] objectForKey:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        CGFloat width = tableView.bounds.size.width * 0.5;
        CGFloat height = [_sbentity.introduce boundingRectWithSize:CGSizeMake(width, MAX_INPUT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _introduceCell.detailTextLabel.font} context:nil].size.height + 20;
        return height;
    }
    return 39;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = _dataModel[indexPath.row][@"cell"];
    if (cell == _hostryCell) {
        ChatHistoryVC* vc = [[ChatHistoryVC alloc]initWithSubscribeID:_sbid];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
