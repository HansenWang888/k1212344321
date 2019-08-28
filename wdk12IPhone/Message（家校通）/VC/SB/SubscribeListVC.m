//
//  SubscribeListVC.m
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeListVC.h"
#import "SubscribeModule.h"
#import "ChatVIewController.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "SubscribeInfoController.h"
#import "ViewSetUniversal.h"
#import <Masonry.h>
#import "SubscribeEntity.h"
#import "QRViewController.h"
#import "HyperLinkVC.h"
#import "ViewSetUniversal.h"
#import "DDNotificationHelp.h"
#import "IMSearchSubscribeVC.h"
@implementation SBInfoCell

- (void)awakeFromNib {
//    UIView *vv = [UIView new];
//    vv.backgroundColor = [UIColor clearColor];
//    vv.bounds = self.frame;
//    UIView *selectedV = [[UIView alloc] init];
//    selectedV.backgroundColor =  COLOR_Creat(67, 79, 90, 1);
//    [vv addSubview:selectedV];
//    [selectedV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(vv).offset(8);
//        make.right.equalTo(vv).offset(-8);
//        make.top.bottom.equalTo(vv);
//    }];
//    self.selectedBackgroundView = vv;
}

@end

#import "IMSearchTableVC.h"

@interface SubscribeListVC ()<UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *sections;
@property (nonatomic, weak) UITableViewCell *lastCell;
@property (nonatomic, weak) QRViewController *QRVC;
/*@"section" / @"model"*/
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataModel;

@end
@implementation SubscribeListVC
{
    
    BOOL _reg;
}
-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle: style];

    //进行排序
    [self sortmodel];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(localPrepared) name:DDNotificationLocalPrepared object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancleSubscribeAttentionNotify:) name:DDNotificationCancleAttention object:nil];

    return self;
}
- (void)localPrepared {
    [self.tableView reloadData];
}
- (void)cancleSubscribeAttentionNotify:(NSNotification *)info {
    //取消关注
    [self cancleSubscribeAttentionWithObjId:info.object];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sortmodel];
    [self.tableView reloadData];
}
//数据排序
- (void)sortmodel {
    _dataModel = @[].mutableCopy;
    NSMutableArray *sectionsM = @[].mutableCopy;
    NSArray *entities = [[SubscribeModule shareInstance]getSubs];
    if (entities.count == 0) {
        return;
    }
    BOOL isContinue = YES;
    for (SubscribeAttentionEntity *entity in entities) {
        SubscribeEntity *sb = [[SubscribeModule shareInstance]getSubscribeBySBID:entity.objID];
        NSString *str = [NSString stringWithFormat:@"%c",[self GetFL:sb.name].intValue];
        isContinue = YES;
        //过滤重复
        for (NSDictionary *dict in _dataModel) {
            if ([dict[@"section"] isEqualToString:str]) {
                [dict[@"model"] addObject:entity];
                isContinue = NO;
            }
        }
        if (isContinue) {
            NSMutableArray *arrayM = @[].mutableCopy;
            [arrayM addObject:entity];
            [_dataModel addObject:@{@"section":str,@"model":arrayM}];
            [sectionsM addObject:str];
        }
    }
    _dataModel = [[_dataModel sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1[@"section"] compare:obj2[@"section"]];
    }] mutableCopy];
    if ([_dataModel[0][@"section"] isEqualToString:@"#"]) {
        [_dataModel addObject:_dataModel[0]];
        [_dataModel removeObjectAtIndex:0];
    }
    [sectionsM sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    if ([sectionsM[0] isEqualToString:@"#"]) {
        [sectionsM addObject:sectionsM[0]];
        [sectionsM removeObjectAtIndex:0];
    }
    self.sections = sectionsM;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.title = IMLocalizedString(@"公众号", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(searchBtnClick:)];
    IMSearchTableVC *searchVC = [[IMSearchTableVC alloc] init];
    searchVC.isSearchSubscribe = YES;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchVC];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchResultsUpdater = searchVC;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    //让resultVC成为根控制器
    self.definesPresentationContext = YES;
    self.tableView.sectionIndexColor = [UIColor blackColor];//导航字母的颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attentionSucessful:) name:DDNotificationAttentionSuccessful object:nil];
}
//关注成功的通知
- (void)attentionSucessful:(NSNotification *)info {
    NSString *objID = info.object;
    SubscribeEntity *sbEntity = [[SubscribeModule shareInstance]getSubscribeBySBID:objID];
    NSString *str = [NSString stringWithFormat:@"%c",[self GetFL:sbEntity.name].intValue];
    int i = 0;
    BOOL isExsit = NO;
    for (NSDictionary *dict  in _dataModel) {
        i++;
        if ([dict[@"section"] isEqualToString:str]) {
            //如果有这个组,直接加入对应的组
            [dict[@"model"] addObject:sbEntity];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[dict[@"model"] count] - 1 inSection:i]] withRowAnimation:0];
            isExsit = YES;
        }
    }
    if (!isExsit) {
        //如果不存在就创建组
        NSMutableArray *models = @[].mutableCopy;
        [models addObject:sbEntity];
        [_dataModel addObject:@{@"section": str, @"model":models}];
        _dataModel = [[_dataModel sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1[@"section"] compare:obj2[@"section"]];
        }] mutableCopy];
        [self.sections addObject:str];
        self.sections = [[self.sections sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }] mutableCopy];
        [self.sections addObject:self.sections[0]];
        [self.sections removeObjectAtIndex:0];
        [self.dataModel addObject:self.dataModel[0]];
        [self.dataModel removeObjectAtIndex:0];
        for (int i = 0; i< _dataModel.count; ++i) {
            NSDictionary *dict = _dataModel[i];
            if ([dict[@"section"] isEqualToString:str]) {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:0];
            }
        }
    }
}
//二维码
- (void)addSubscribeBtnClick {
    
    QRViewController *vc = [[QRViewController alloc] init];
    self.QRVC = vc;
    vc.qrUrlBlock = ^(NSString *url){
        if ([url hasPrefix:@"http://"]) {
            //如果是http请求就用网页展示
            HyperLinkVC *vc = [[HyperLinkVC alloc] initWithHyperLink:url AndTitle:IMLocalizedString(@"网页内容", nil)];
            [self.navigationController pushViewController:vc animated:YES];
            return ;
        }
        [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
        NSArray* array = [url componentsSeparatedByString:@"_"];
        if(array.count ==2){
            
            [[SubscribeModule shareInstance]getSubscribeByUUID:array[0] Differno:array[1] Block:^(SubscribeEntity *sbentity) {
                if(sbentity != nil){
                    [SVProgressHUD dismiss];
                    SubscribeInfoController* vc = [[SubscribeInfoController alloc]initWithSBID:sbentity.objID];
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"获取失败", nil)];
                }
            }];
        }
        else{
            [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"获取失败", nil)];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}
//搜索
- (void)searchBtnClick:(UIButton *)btn {
    IMSearchSubscribeVC *vc = [IMSearchSubscribeVC new];
    [self.navigationController pushViewController:vc animated:YES];
//    SearchUserViewController *vc = [SearchUserViewController new];
//    self.searchVC = vc;
//    vc.isSearchSubscribe = YES;
//    [self setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (UIBarButtonItem *)creatBarButtonWithTitle:(NSString *)title action:(SEL)action {
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:title style:0 target:self action:action];
    barBtn.tintColor = [UIColor whiteColor];
    return barBtn;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataModel.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataModel[section][@"model"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* CELL_ID = @"SBInfoCell";
    if(!_reg){
        _reg = YES;
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
    }
    
    SBInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    SubscribeAttentionEntity* sbattentity = _dataModel[indexPath.section][@"model"][indexPath.row];
    [cell.naleLabel setSBID:sbattentity.objID];
    [cell.avatarImageView setSBID:sbattentity.objID];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _dataModel[section][@"section"];
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView __TVOS_PROHIBITED {

    return self.sections;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.selected = YES;
//    if (cell == self.lastCell && (indexPath.row != _dataModel.count)) {
//        return;
//    }
//    self.lastCell = cell;

    SubscribeAttentionEntity* sbattentity = _dataModel[indexPath.section][@"model"][indexPath.row];
    SubscribeInfoController *infoVC = [[SubscribeInfoController alloc] initWithSBID:sbattentity.objID];
    [self.navigationController pushViewController:infoVC animated:YES];
    [infoVC.navigationController setNavigationBarHidden:NO animated:YES];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){
    UITableViewRowAction* delaction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:IMLocalizedString(@"取消关注", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    SubscribeAttentionEntity* sbattentity = _dataModel[indexPath.section][@"model"][indexPath.row];
        __weak typeof(self) weakSelf = self;
       [[SubscribeModule shareInstance]attentionSubscribe:sbattentity.objID Attention:SubscribeOptCancelsubscribe Block:^(NSError *error) {
           if(!error){
               [_dataModel[indexPath.section][@"model"] removeObject:sbattentity];
               [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
               if([_dataModel[indexPath.section][@"model"] count] == 0){
                   [_dataModel removeObject:_dataModel[indexPath.section]];
                   [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:0];
               }
               [SVProgressHUD dismiss];
           }
           else{
               [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error=%@,code=%d",error.domain,error.code]];
           }
       }];
        
    }];
    
    return @[delaction];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    UITableViewHeaderFooterView *head = (UITableViewHeaderFooterView *)view;
    head.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    head.textLabel.textColor = [UIColor grayColor];
    head.textLabel.font = [UIFont systemFontOfSize:12];
}
- (void)cancleSubscribeAttentionWithObjId:(NSString *)objID {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[SubscribeModule shareInstance]attentionSubscribe:objID Attention:SubscribeOptCancelsubscribe Block:^(NSError *error) {
        if(!error){
            [SVProgressHUD dismiss];
            for (NSDictionary *dict  in weakSelf.dataModel) {
                for (SubscribeAttentionEntity* sbattentity in dict[@"model"]) {
                    if ([sbattentity.objID isEqualToString:objID]) {
                        NSInteger sectionIndex = [_dataModel indexOfObject:dict];
                        NSInteger index = [dict[@"model"] indexOfObject:sbattentity];
                        [dict[@"model"] removeObject:sbattentity];
                        [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:sectionIndex]] withRowAnimation:0];
                        if ([dict[@"model"] count] == 0) {
                            //如果组内没有一个数据就删除组
                            [weakSelf.sections removeObjectAtIndex:sectionIndex];
                            [_dataModel removeObject:dict];
                            [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:0];
                        }
                    }
                }
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error=%@,code=%ld",error.domain,(long)error.code]];
        }
    }];

}
#pragma mark 汉字拼音首字母排序
-(NSNumber*)GetFL:(NSString*)word{
    char fl = getFirstChar(word);
    if(fl>='a'&&fl<='z') fl -= 32;
    return [NSNumber numberWithChar:fl];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
