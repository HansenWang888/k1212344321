#import "SearchUserViewController.h"
#import "uicolor+hex.h"
#import "ContactModule.h"
#import "userAbstractCell.h"
#import "UserInfoViewController.h"
#import "ContactDataModel.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import "UIImageView+WebCache.h"
#import "SubscribeInfoController.h"
#import <Masonry.h>
#import "UIImage+FullScreen.h"
#import "SearchSubscribeCell.h"
UIView* RecursiveGetSubViewByClassName(NSString* classname,UIView* parent){
   
    for(UIView* subview in parent.subviews){
       
        if([subview isKindOfClass:NSClassFromString( classname)]) {
            return subview;
        }
        else{
            UIView* ret =  RecursiveGetSubViewByClassName(classname, subview);
            if(ret) return ret;
        }
    }
    return nil;
}
@interface SearchUserViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchUserViewController
{
    NSMutableArray* _users;
    NSArray* _sbs;
    UITableView* _baseTableView;
}

-(id)init{
    self = [super init];
    _users = [NSMutableArray new];
    self.title = IMLocalizedString(@"搜索", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor groupTableViewBackgroundColor];
    [self.navigationItem setHidesBackButton:YES];
    self.searchBar = [UISearchBar new];
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.placeholder = IMLocalizedString(@"查找好友", nil);
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar setShowsCancelButton:YES animated:YES];
//    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    [self initTableView];
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.searchBar becomeFirstResponder];
//    [self.searchController.searchBar becomeFirstResponder];
}

-(void)initTableView{

    _baseTableView = [[UITableView alloc]init];
    [_baseTableView registerNib:[UINib nibWithNibName:@"SearchSubscribeCell" bundle:nil] forCellReuseIdentifier:@"subCell"];
    _baseTableView.dataSource = self;
    _baseTableView.delegate = self;
    [self.view addSubview:_baseTableView];
    _baseTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _baseTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [_baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    _baseTableView.tableFooterView = [UIView new];

}
- (void)setIsSearchSubscribe:(BOOL)isSearchSubscribe {
    _isSearchSubscribe = isSearchSubscribe;
    NSMutableAttributedString *strM = [[NSMutableAttributedString alloc] init];
    if (self.isSearchSubscribe) {
        [strM appendAttributedString:[[NSAttributedString alloc] initWithString:IMLocalizedString(@"搜索公众号获取最新资讯", nil)]];
    } else {
        [strM appendAttributedString:[[NSAttributedString alloc] initWithString:IMLocalizedString(@"搜索用户", nil)]];
    }
    [strM addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, strM.mutableString.length)];
    _searchBar.placeholder = strM.string;
}
//MARK:search Delegate
//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchDataWithText:searchBar.text];
    [searchBar endEditing:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchDataWithText:(NSString *)text {
    if (self.isSearchSubscribe) {
        //公众号
        [[SubscribeModule shareInstance] SearchSubscribe:text Block:^(NSArray<SubscribeEntity *> *sbAry) {
            if (sbAry) {
                
                _sbs = sbAry;
                [_baseTableView reloadData];
            }
        }];
        
        return;
    }
    [[ContactModule shareInstance]SearchUser:text Block:^(NSMutableArray *users,NSMutableArray* sbs) {
        if(users != nil){
            _users = users;
            
            [_baseTableView reloadData];
        } 
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchDataWithText:textField.text];
    [textField endEditing:YES];
    return YES;
}
#pragma mark TABLEVIEW_DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearchSubscribe) {
        return _sbs.count;
    }
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.isSearchSubscribe){
        //搜索用户
        DDUserEntity* uentity = [_users objectAtIndex:indexPath.row];
        UserAbstractCell* ret = nil;
        ret = [tableView dequeueReusableCellWithIdentifier:uentity.objID];
        if(ret) return ret;
        ret = [[UserAbstractCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uentity.objID];
//        ret.isAddAccessoryView = YES;
        ret.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ContactUserAbstract* userabstract = [ContactUserAbstract new];
        userabstract.uid = uentity.objID;
        userabstract.nick = uentity.nick;
        userabstract.avatar = uentity.avatar;
        ret.userAbstrct = userabstract;
        return ret;
    }
    //搜索公众号
    SearchSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subCell" forIndexPath:indexPath];
    SubscribeEntity *entity = _sbs[indexPath.row];
    cell.subEntity = entity;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar endEditing:YES];
    if(!self.isSearchSubscribe){
        UserAbstractCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        assert(cell.userAbstrct );
//        [_textFiled endEditing:YES];
        UserInfoViewController* vc = [UserInfoViewController new];
        vc.isContactVC = YES;
        vc.UserID = cell.userAbstrct.uid;
        vc.title = cell.userAbstrct.nick;
        [self.navigationController pushViewController:vc animated:YES];
//        if ([self.searchDelegate respondsToSelector:@selector(searchUserCelldidSelectedForVC:)]) {
//            [self.searchDelegate searchUserCelldidSelectedForVC:controller];
//        }
        return;
    }
    SubscribeEntity* sbentity = _sbs[indexPath.row];
    SubscribeInfoController* vc = [[SubscribeInfoController alloc]initWithSBID:sbentity.objID];
//    if ([self.searchDelegate respondsToSelector:@selector(searchUserCelldidSelectedForVC:)]) {
//        [self.searchDelegate searchUserCelldidSelectedForVC:vc];
//    }
    vc.title = sbentity.name;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}

@end
