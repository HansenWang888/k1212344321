#import "FriendVerifyListViewController.h"
#import "ContactModule.h"
#import "VerifyEntity.h"
#import "verifyCell.h"
#import "SearchUserViewController.h"

@interface FriendVerifyListViewController ()<VerifyCellDelegate>

@end
@implementation FriendVerifyListViewController
{
    NSMutableArray* _dataModel;
    BOOL _reg;
}
-(id)init{
    self = [super init];
    _reg = NO;
    return self;
}
-(void)viewDidLoad{
    self.title = IMLocalizedString(@"新朋友", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self getVerifyList];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getVerifyList) name:DDNotificationVerifyListRefresh object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:IMLocalizedString(@"添加朋友", nil) style:0 target:self action:@selector(rightItemClick)];
    
}
- (void)rightItemClick {
    //添加新朋友...
    SearchUserViewController *userVC = [SearchUserViewController new];
    [self.navigationController pushViewController:userVC animated:YES];
//    [userVC.navigationController setNavigationBarHidden:YES animated:YES ];
}
-(void)getVerifyList{
    _dataModel = [[NSMutableArray alloc]initWithArray:[[ContactModule shareInstance]getAllVerify]];
    
    [self.tableView reloadData];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataModel.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VerifyEntity* ventity = _dataModel[indexPath.row];
    NSString* CELL_ID = @"VerifyCell";
    if(!_reg){
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
        _reg = YES;
    }
    VerifyCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID  forIndexPath:indexPath];
    cell.verifyDelegate = self;
    [cell setUidAndVerify:ventity.objID Verify:ventity.verify];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0){
    return NO;
}
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//}
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){
//    UITableViewRowAction* acceptaction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"同意" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//
//
//    }];
//    acceptaction.backgroundColor = [UIColor greenColor];
//    UITableViewRowAction* delaction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"拒绝" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//           }];
//
//    return @[delaction,acceptaction];
//}
#pragma mark - VerifyCellDelegate
- (void)agreeAddition:(NSString *)verifyID {
    VerifyEntity *ventity = [[ContactModule shareInstance] getVerifyWithVerifyID:verifyID];
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeGradient];
    [[ContactModule shareInstance]acceptFriendVerify:ventity Block:^(NSError * error) {
        if(!error) {
            [SVProgressHUD dismiss];
            NSInteger i = [_dataModel indexOfObject:ventity];
            [_dataModel removeObject:ventity];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0 ]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"code:%ld domain:%@",error.code,error.domain]];
        }
    }];
}
- (void)refuseAddition:(NSString *)verifyID {
    VerifyEntity* ventity = [[ContactModule shareInstance] getVerifyWithVerifyID:verifyID];
    NSInteger i = [_dataModel indexOfObject:ventity];
    [_dataModel removeObject:ventity];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:0];
    [[ContactModule shareInstance]denialFriendVerify:ventity Block:^(NSError *error) {
        
    }];
}
@end
