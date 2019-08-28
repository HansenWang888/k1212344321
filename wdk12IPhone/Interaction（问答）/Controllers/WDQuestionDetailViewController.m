//
//  WDQuestionDetailViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDQuestionDetailViewController.h"
#import "WDQuestionModel.h"
#import "UIImageView+WebCache.h"
#import "WDHTTPManager.h"
#import "WDAnswerDetailModel.h"
#import "WDAnswerDetailCell.h"
#import "WDReplyView.h"
#import "WDAnswerByMeViewController.h"

@interface WDQuestionDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
//头视图
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *questionType;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *promotView;//遮罩
@property (nonatomic, strong) WDReplyView *replyView;//回复view

@property (nonatomic, strong) NSString *endId;
@property (nonatomic, strong) NSMutableArray<WDAnswerDetailModel *> *dataArray;
@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;

@property (nonatomic,assign) BOOL isCaiNa;
@property (nonatomic,assign) BOOL isMe;

@end

@implementation WDQuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settings];
    
    [self setupHeaderView];

    [self getAnswerData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WDAnswerDetailCell" bundle:nil] forCellReuseIdentifier:@"WDAnswerDetailCell"];
}

//刷新
- (IBAction)refreshData:(id)sender {
    [self getAnswerData];
}

#pragma maek --- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    WDAnswerDetailModel *model = self.dataArray[section];
    
    return model.hfxxList.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WDAnswerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WDAnswerDetailCell"];
    
    WDAnswerDetailModel *model = self.dataArray[indexPath.section];
    cell.isCaiNa = self.isCaiNa;
    //回答
    if (indexPath.row == 0) {
        [cell setCellWithModel:model isFirst:YES isMe:self.isMe];
        
        [cell.contentLabel layoutIfNeeded];
        [cell.contentView layoutIfNeeded];
        
        CGFloat H = MAX(CGRectGetMaxY(cell.contentLabel.frame) + 20, 100);
        
        [self.cellHeightCache setObject:@(H) forKey:[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row]];
    }else {//回复
        WDAnswerDetailModel *secModel = model.hfxxList[indexPath.row-1];
        [cell setCellWithModel:secModel isFirst:NO isMe:self.isMe];
        
        [cell.contentLabel layoutIfNeeded];
        [cell.contentView layoutIfNeeded];
        
        CGFloat H = MAX(CGRectGetMaxY(cell.contentLabel.frame) + 20, 80);
        
        [self.cellHeightCache setObject:@(H) forKey:[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row]];
    }
    WEAKSELF(self);
    cell.huifuBlock = ^(WDAnswerDetailModel *huifuModel){
        [weakSelf huifuWithModel:huifuModel];
    };
    
    cell.cainaBlock = ^(WDAnswerDetailModel *cainaModel){
        [weakSelf cainaWithModel:cainaModel];
    };
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat H = [self.cellHeightCache[[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row]] doubleValue];
    NSLog(@"section : %ld row : %ld H :%f",indexPath.section,indexPath.row,H);
    
    return H;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = self.view.backgroundColor;
}

#pragma mark  --- 回答数据
-(void)getAnswerData {

    WDTeacher * teacher = [WDTeacher sharedUser];
    
    if ([teacher.teacherID isEqualToString:self.model.twrID]) {
        self.isMe = YES;
    }else {
        self.isMe = NO;
    }
    
    NSDictionary * httpDic = @{
                               @"xxID":teacher.schoolID,
                               @"wtID":self.model.questionId,
                               @"startID":!_endId?@"":_endId,
                               @"ts":@"10",
                               @"yhlx":teacher.userType
                               };
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!getSYHDList.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        [SVProgressHUD dismiss];
        NSArray *array = [dic objectForKey:@"hdList"];
        [self.dataArray removeAllObjects];
        //是否被采纳答案
        NSMutableArray *temArr = @[].mutableCopy;
        for (NSDictionary *dict in array) {

            WDAnswerDetailModel *model = [WDAnswerDetailModel getAnswerDetailModelWith:dict];
            if ([model.sfcn isEqualToString:@"true"]) {
                [temArr insertObject:model atIndex:0];
                self.isCaiNa = YES;
            }else {
                [temArr addObject:model];
            }
        }
        self.dataArray.array = temArr;
        [self.tableView reloadData];
    }];
}

#pragma mark -- 回复
- (void)huifuWithModel:(WDAnswerDetailModel *)model {
    [self.view bringSubviewToFront:self.promotView];
    [self.view bringSubviewToFront:self.replyView];
    self.promotView.hidden = NO;
    self.replyView.hidden = NO;
    [self.replyView becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.replyView.transform = CGAffineTransformIdentity;
    }];
    WEAKSELF(self);
    //关闭
    self.replyView.closeBlock = ^{
        [weakSelf dismissHuifuView];
    };
    //确定
    self.replyView.confirmBlock = ^(NSString *text) {
    
        if (!text || !text.length) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入回答内容!", nil)];
            return;
        }
        WDTeacher * teacher = [WDTeacher sharedUser];
        NSDictionary * httpDic = @{
                                   @"wtID":weakSelf.model.questionId,
                                   @"hdID":model.hdID,
                                   @"userID":teacher.teacherID,
                                   @"hdwz":text,
                                   @"yhlx":teacher.userType
                                   };
        [SVProgressHUD showWithStatus:@""];
        [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!tjwthf.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
            [SVProgressHUD dismiss];
            if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
                //回复成功
                [weakSelf getAnswerData];
                [weakSelf dismissHuifuView];
            }else{
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"回复失败！", nil)];
            }
        }];
    };
    
}

- (void)dismissHuifuView {
    [UIView animateWithDuration:0.3 animations:^{
        self.replyView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        self.promotView.hidden = YES;
        self.replyView.hidden = YES;
        [self.replyView reset];
    }];
}

#pragma mark -- 采纳
- (void)cainaWithModel:(WDAnswerDetailModel *)hdModel {
    WDTeacher * teacher = [WDTeacher sharedUser];
    //发送采纳
    
    NSDictionary * httpDic = @{
                               @"wthjID":self.model.hjID,
                               @"wtID":self.model.questionId,
                               @"hdID":hdModel.hdID,
                               @"hdhjID":hdModel.hdhjID,
                               @"hdrID":hdModel.hdrID,
                               @"wtym": self.questionYM,
                               @"userID":teacher.teacherID,
                               @"hdzlx":hdModel.hdzlx
                               };
    [SVProgressHUD show];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!cnwthd.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"采纳成功", nil)];
            [self getAnswerData];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"采纳失败", nil)];
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma mark -- 头视图
- (void)setupHeaderView {
    if (!_model) return;
    
    //头像 姓名
    if ([self.model.sfnm isEqualToString:@"true"]) {
        self.iconImageView.image = [UIImage imageNamed:@"default_touxiang"];
        self.nameLabel.text = NSLocalizedString(@"***", nil);
    }else {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.model.icon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        self.nameLabel.text = self.model.twr;
    }
    
    //回答个数
    self.answerNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"有%d个回答", nil),self.model.hds];
    
    //标题
    NSString *titleStr = [self.model.wtlx isEqualToString:@"2"] ? self.model.ztzt : self.model.wtwz;
    if (!titleStr || !titleStr.length) {
        titleStr = NSLocalizedString(@"图片问题", nil);
    }
    self.titleLabel.text = titleStr;
    
    //时间
    self.dateLabel.text = self.model.twrq;
    
    //课程描述
    self.courseLabel.text = [NSString stringWithFormat:@"%@%@%@%@", self.model.km,self.model.nj,self.model.cb,self.model.jcbbmc];

    //问题类型
    NSString * wtlx;
    if ([self.model.wtlx isEqualToString:@"1"]) {
        wtlx = NSLocalizedString(@"课程疑问", nil);
        self.questionType.textColor = [UIColor hex:0xF7B964 alpha:1];
    }else if ([self.model.wtlx isEqualToString:@"2"]){
        wtlx = NSLocalizedString(@"专题讨论", nil);
        self.questionType.textColor = [UIColor hex:0x61B961 alpha:1];
    }else if ([self.model.wtlx isEqualToString:@"3"]){
        wtlx = NSLocalizedString(@"其他问题", nil);
        self.questionType.textColor = [UIColor hex:0xA453CE alpha:1];
    }
    self.questionType.text = wtlx;
    
    //内容
    NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 13px; font-weight:bold;width:100%%;}img{max-width:%f !important;}</style></html>", self.model.wtfwbnr, [UIScreen wd_screenWidth] - 150];
    
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.attributedText = attr1;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 120;
    [self.contentLabel layoutIfNeeded];
    [self.headerView layoutIfNeeded];
    
    self.headerView.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth], MAX(CGRectGetMaxY(self.contentLabel.frame), CGRectGetMaxX(self.answerNumLabel.frame)));
    self.tableView.tableHeaderView = self.headerView;

}

- (void)settings {
    
    _endId = @"";
    _dataArray = @[].mutableCopy;
    _cellHeightCache = @{}.mutableCopy;
    self.title = NSLocalizedString(@"问题详情", nil);
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.replyView = [[[NSBundle mainBundle] loadNibNamed:@"WDReplyView" owner:nil options:nil] firstObject];
    [self.view insertSubview:self.replyView belowSubview:self.tableView];
    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.offset(70);
        make.height.mas_equalTo(@(300*([UIScreen wd_screenWidth]/375.0)));
    }];
    
    self.refreshBtn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:22];
    [self.refreshBtn setTitle:@"\U0000E62e" forState:UIControlStateNormal];
    self.tableView.estimatedRowHeight = 100.0f;
    
    //添加nav右侧按钮
    UIButton * editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.backgroundColor = [UIColor clearColor];
    [editBtn setTitle:NSLocalizedString(@"我来回答", nil) forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    editBtn.frame = CGRectMake(0, 0, 80, 40);
    editBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    [editBtn addTarget:self action:@selector(clickNavRightBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    
    self.promotView.userInteractionEnabled = YES;
    [self.promotView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHuifuView)]];
}
//右侧按钮点击
-(void)clickNavRightBtn {
    WDAnswerByMeViewController *anVC = [[WDAnswerByMeViewController alloc] init];
    anVC.model = self.model;
    
    
    if ([self.questionYM isEqualToString:@"sywt"]) {
        anVC.questionYM = @"qb";
    }else {
        anVC.questionYM = @"wd";
    }
    WEAKSELF(self);
    anVC.successBlock = ^{
        self.model.hds += 1;
        self.answerNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"有%d个回答", nil),self.model.hds];
        [weakSelf getAnswerData];
    };
    [self.navigationController pushViewController:anVC animated:YES];
}

@end
