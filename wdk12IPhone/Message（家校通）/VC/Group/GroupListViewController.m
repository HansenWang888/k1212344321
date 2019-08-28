#import "GroupListViewController.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import "groupCell.h"
#import "ChatVIewController.h"
#import "UIImage+FullScreen.h"
#import "ViewSetUniversal.h"
#import "ChatVIewController.h"
#import "GroupEntity.h"
@interface GroupListViewController ()<UISearchBarDelegate>
@property (nonatomic, copy) NSArray *lastArray;//保存搜索前的数据

@end
@implementation GroupListViewController
{
    NSMutableArray* _dataModel;
    UISearchBar * _searchBar;
    BOOL _reg;
}
-(void)viewDidLoad{
   
    self.title = IMLocalizedString(@"会话组", nil);
    _reg = NO;
    self.tableView.tableFooterView = [[UIView alloc]init];
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.searchBarStyle =UISearchBarStyleMinimal;
    _searchBar.placeholder = IMLocalizedString(@"搜索", nil);
    _searchBar.frame = CGRectMake(0, 0, 0, 44);
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    [self GetContactGroups];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ContactRefreshed) name:DDNotificationContactRefresh object:nil];
}
- (void)rightBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)GetContactGroups{
    _dataModel = [NSMutableArray new];
    [[[ContactModule shareInstance]GetContact] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ContactInfoEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj isContactGroup]){
            [_dataModel addObject:obj];
        }
    }];
    [self.tableView reloadData];
}
-(void)ContactRefreshed{
    [self GetContactGroups];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ 
    return _dataModel.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CELL_ID = @"GroupCell";
    
    ContactInfoEntity* centity = _dataModel[indexPath.row];
    if(!_reg){
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
        _reg = YES;
    }
    GroupCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID  forIndexPath:indexPath];
    [cell setGroupID:centity.objID];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactInfoEntity* centity = _dataModel[indexPath.row];
    ChatViewController *vc = [ChatViewController initWithGroupID:centity.objID];
    [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],vc] animated:YES];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.lastArray = _dataModel.copy;
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //search....
    [self searchDataWithText:searchText];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //search...
    [self searchDataWithText:searchBar.text];
}
- (void)searchDataWithText:(NSString *)text {
    NSMutableArray *arrayM = @[].mutableCopy;
    [self.lastArray enumerateObjectsUsingBlock:^(ContactInfoEntity *entity, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupEntity *gentity = [[DDGroupModule instance] getGroupByGId:entity.objID];
        if (gentity) {
            [arrayM addObject:gentity];
        }
    }];
    NSArray *array = [arrayM filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name CONTAINS '%@'",text]]];
    NSMutableArray *results = @[].mutableCopy;
    [array enumerateObjectsUsingBlock:^(GroupEntity *gentity, NSUInteger idx, BOOL * _Nonnull stop) {
        ContactInfoEntity *infoEntity = [[ContactInfoEntity alloc] initWithGid:gentity.objID];
        if (infoEntity) {
            [results addObject:infoEntity];
        }
    }];
    _dataModel = results;
    [self.tableView reloadData];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    _dataModel = self.lastArray.mutableCopy;
    [self.tableView reloadData];
}
@end
