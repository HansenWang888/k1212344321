//
//  ReportViewController.m
//  wdk12IPhone
//
//  Created by macapp on 15/11/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ReportViewController.h"
#import "SessionEntity.h"
#import "SessionModule.h"
#import "SVProgressHUD.h"
@interface ReportViewController ()

@end

@implementation ReportViewController
{
    NSArray* _dataModel;
    NSInteger _currentIndex;
    SessionEntity* _sentity;
}

-(id)initWithSession:(SessionEntity*)session{
    self = [super init];
    _dataModel = @[@"色情低俗",@"广告骚扰",@"政治敏感",@"谣言",@"欺诈骗钱",@"违法 (暴力恐怖、违禁品等)"];
    _currentIndex = -1;
    _sentity = session;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:IMLocalizedString(@"提交" , nil) style:UIBarButtonItemStyleBordered target:self action:@selector(commit)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(void)commit{
    [[SessionModule sharedInstance]reportSession:_sentity Info:_dataModel[_currentIndex]];
    
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:nil];
        [self.navigationController popViewControllerAnimated:YES];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    NSArray *dataModel =
    @[@"色情低俗", @"广告骚扰", @"政治敏感", @"谣言", @"欺诈骗钱", @"违法 (暴力恐怖、违禁品等)"];
    cell.textLabel.text = IMLocalizedString(dataModel[indexPath.row], nil);
    if(indexPath.row == _currentIndex){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _currentIndex) return;
    
    if(_currentIndex != -1){
        NSIndexPath* old = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:old];
        if(cell) cell.accessoryType = UITableViewCellAccessoryNone;

    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _currentIndex = indexPath.row;
}
@end
