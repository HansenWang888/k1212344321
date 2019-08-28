//
//  WDMyQuestionViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDMyQuestionViewController.h"
#import "WDHTTPManager.h"
#import "WDQuestionModel.h"
#import "WDQuestionCell.h"
#import "WDAnsweredQuestionCell.h"
#import "MJRefresh.h"
#import "WDQuestionDetailViewController.h"

@interface WDMyQuestionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *myQuestionEndId;

@property (nonatomic, strong) NSMutableArray<WDQuestionModel *> *myQuestionArr;

@property (nonatomic,assign) BOOL isHttping;//防止重复请求

@end

@implementation WDMyQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUP];
    
    [self getMyQuestionData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];

}

- (void)setUP {

    _myQuestionEndId = @"";
    self.myQuestionArr = @[].mutableCopy;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"WDQuestionCell" bundle:nil] forCellReuseIdentifier:@"WDQuestionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WDAnsweredQuestionCell" bundle:nil] forCellReuseIdentifier:@"WDAnsweredQuestionCell"];
    
    //设置上下拉刷新
    self.tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(updateData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myQuestionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WDQuestionModel *model = self.myQuestionArr[indexPath.row];

    if (model.cnList.count) {
        WDAnsweredQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDAnsweredQuestionCell"];
        cell.answerQuestionModel = model;
        return cell;
    }else {
        WDQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDQuestionCell"];
        cell.questionModel = model;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WDQuestionModel *model = self.myQuestionArr[indexPath.row];
    if (model.cnList.count) {
        
        NSString *answer = [[model.cnList firstObject] hdwz];
        
        CGRect rect = [answer boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-(43+45), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]} context:nil];
        
        CGFloat H = MIN(rect.size.height+148, 300);
        NSLog(@"H =====>%f",H);
        return H > 196 ? H : 196;
    }else {
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WDQuestionModel *model = self.myQuestionArr[indexPath.row];

    WDQuestionDetailViewController *detailVC = [[WDQuestionDetailViewController alloc] init];
    detailVC.model = model;
    detailVC.questionYM = @"wdwt";
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.parentViewController.navigationController pushViewController:detailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        WDQuestionModel *model = self.myQuestionArr[indexPath.row];

        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"确定删除？", nil) message:@"" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:(UIAlertActionStyleCancel) handler:nil];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            [self deleteQuestion:model indexPath:indexPath];
        }];
        [alertCtrl addAction:action1];
        [alertCtrl addAction:action2];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
}
//删除问题
- (void)deleteQuestion:(WDQuestionModel *)model indexPath:(NSIndexPath *)indexPath{
    WDTeacher  *teacher = [WDTeacher sharedUser];
    
    NSDictionary * httpDic = @{
                               @"wthjID":model.hjID,
                               @"userID":teacher.teacherID,
                               @"yhlx":teacher.userType
                               };
    
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!deletewt.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            //成功
            [self.myQuestionArr removeObject:model];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"删除失败！", nil)];
        }
    }];
}

-(void)getMyQuestionData{
    if (self.isHttping) return;
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    NSDictionary * httpDic = @{
                               @"xxID":teacher.schoolID,
                               @"userID":teacher.teacherID,
                               @"startID":_myQuestionEndId,
                               @"ts":@"10",
                               @"yhlx":teacher.userType
                               };
    self.isHttping = YES;
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wdv1!getWDWTLIST.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
    
        [SVProgressHUD dismiss];
        
        if (!_myQuestionEndId.length) {
            [self.myQuestionArr removeAllObjects];
            [self.tableView reloadData];
        }
        
        _myQuestionEndId = [dic objectForKey:@"endID"];
        
        //加数据
        NSArray * justAry = [dic objectForKey:@"wtList"];
        for (NSDictionary *dict in justAry) {
            WDQuestionModel *model = [WDQuestionModel getQuestionModelWith:dict];
            [self.myQuestionArr addObject:model];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        self.isHttping = NO;
    }];
    
}

- (void)updateData {
    _myQuestionEndId = @"";
    [self getMyQuestionData];
}

- (void)loadMoreData {
    if ([_myQuestionEndId isEqualToString:@""]) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return ;
    }
    [self getMyQuestionData];
}

@end
