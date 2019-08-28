//
//  interactionDetailViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/3.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "interactionDetailViewController.h"
#import "interactionDetailCell.h"
#import "SecondDetailCell.h"
#import "WDHTTPManager.h"
#import "UIImageView+WebCache.h"
#import "InteractionReplyViewController.h"
#import "AnswerWillViewController.h"
#import "InteractionViewController.h"


@interface interactionDetailViewController () {
    NSMutableArray * dataAry;
    NSString * endId;
    NSMutableArray * textViewHeights; //记录所有cell的textView的高度
    InteractionReplyViewController * replyVc;
    BOOL isCN;//采纳 采纳 采纳
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *myHeadView;
//TableViewHeadView
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UILabel *headTime;
@property (weak, nonatomic) IBOutlet UILabel *headDescribe;
@property (weak, nonatomic) IBOutlet UILabel *headType;
@property (weak, nonatomic) IBOutlet UIButton *myRefreshBtn;
///  缓存行高
@property (nonatomic, strong) NSMutableDictionary *cellHeightCache;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerNumLabel;

@end

@implementation interactionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Details of the problem", nil);
    //添加nav右侧按钮
    UIButton * editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.backgroundColor = [UIColor clearColor];
    [editBtn setTitle:NSLocalizedString(@"I'll answer", nil) forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    editBtn.frame = CGRectMake(0, 0, 80, 40);
    editBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    [editBtn addTarget:self action:@selector(clickNavRightBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    
    //设置问题图片
    [self settingHeaderViewImage];
    
    //监听回复成功以后
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyOk) name:@"replyOk" object:nil];
    
    //获取回答列表
    endId = @"";
    [self requestData];

//   设置btn的图标 iconfont
    self.myRefreshBtn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:22];
    [self.myRefreshBtn setTitle:@"\U0000E661" forState:UIControlStateNormal];
    
    self.cellHeightCache = [NSMutableDictionary dictionary];
    self.myTableView.estimatedRowHeight = 100.0f;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clickNavRightBtn
{
    AnswerWillViewController * answerVc = [[AnswerWillViewController alloc]init];
    answerVc.info = self.infoDic;
    [self.navigationController pushViewController:answerVc animated:YES];
}
-(void)requestData {
//    NSLog(@"%@",self.infoDic);
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    NSDictionary * httpDic = @{@"xxID":teacher.schoolID,
                               @"wtID":[self.infoDic objectForKey:@"id"],
                               @"startID":endId,
                               @"ts":@"10",
                               @"yhlx":teacher.userType};
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!getSYHDList.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
        //数据
        dataAry = [[NSMutableArray alloc]init];
        dataAry = [dic objectForKey:@"hdList"];
        
        
        //是否被采纳答案
        for (NSDictionary * dic in dataAry) {
            if ([[dic objectForKey:@"sfcn"]isEqualToString:@"true"]) {
                isCN = YES;
                break;
            }
        }
        
        [self.myTableView reloadData];
        [SVProgressHUD dismiss];
    }];
}


-(void)settingHeaderViewImage {
    //提问人头像
    if ([self.infoDic[@"sfnm"] isEqualToString:@"true"]) {
        self.userHeadImage.image = [UIImage imageNamed:@"default_touxiang"];
    } else {
        [self.userHeadImage sd_setImageWithURL:[NSURL URLWithString:[self.infoDic objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
    }
    
    //提问人名字
    self.userName.text = [self.infoDic[@"sfnm"] isEqualToString:@"true"] ? NSLocalizedString(@"Anonymous", nil) : [self.infoDic objectForKey:@"twr"];
    self.userName.adjustsFontSizeToFitWidth = true;
    
    //回答个数
    self.answerNumLabel.text = [NSString stringWithFormat:@"有%ld个回答",[self.infoDic[@"hds"] integerValue]];
    
    //标题
    NSString *titleStr = [self.infoDic[@"wtlx"] isEqualToString:@"2"] ? self.infoDic[@"ztzt"] : self.infoDic[@"wtwz"];
    if (!titleStr || !titleStr.length) {
        titleStr = @"图片问题";
    }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[titleStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.headTitle.attributedText = attr;
    self.headTitle.numberOfLines = 0;
    self.headTitle.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;    
    //时间
    self.headTime.text = [self.infoDic objectForKey:@"twrq"];
    
    //课程描述
    self.headDescribe.text = [NSString stringWithFormat:@"%@%@%@", [self.infoDic objectForKey:@"km"],[self.infoDic objectForKey:@"nj"],[self.infoDic objectForKey:@"cb"]];
    self.headDescribe.numberOfLines = 0;
    
    //问题类型
    NSString * wtlx;
    if ([[self.infoDic objectForKey:@"wtlx"] isEqualToString:@"1"]) {
        wtlx = NSLocalizedString(@"Course Questions", nil);
    }else if ([[self.infoDic objectForKey:@"wtlx"] isEqualToString:@"2"]){
        wtlx = NSLocalizedString(@"Seminar", nil);
    }else if ([[self.infoDic objectForKey:@"wtlx"] isEqualToString:@"3"]){
        wtlx = NSLocalizedString(@"Other problems", nil);
    }
    self.headType.text = wtlx;
    NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 13px; font-weight:bold;width:100%%;}img{max-width:%f !important;}</style></html>", self.infoDic[@"wtfwbnr"], [UIScreen wd_screenWidth] - 150];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.attributedText = attr1;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
    [self.contentLabel layoutIfNeeded];
    [self.myHeadView layoutIfNeeded];
    self.myHeadView.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth], MAX(CGRectGetMaxY(self.contentLabel.frame), CGRectGetMaxX(self.userName.frame)));
    self.myTableView.tableHeaderView = self.myHeadView;
}

- (IBAction)clickUpdate:(id)sender {
    
    [self requestData];
}

#pragma mark 监听事件的方法
-(void)replyOk
{
    [self requestData];

}
#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] doubleValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary * dic = dataAry[section];
    //回复列表
    NSArray * hfList = [dic objectForKey:@"hfxxList"];
    
    //回复列表的数量 ＋ 本身的一个回复
    return hfList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * dic = dataAry[indexPath.section];
    
    //第一条会有图片 和 回复按钮
    if (indexPath.row == 0) {
        //第一个
        interactionDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:@"interactionDetailCell"];
        if (cell == nil) {
            cell = [interactionDetailCell interactionCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //判断是否被采纳

        if (isCN) {
            cell.acceptBtn.hidden = YES;
        }else {
            if ([self.infoDic[@"twrID"] isEqualToString:dic[@"hdrID"]]) {
                cell.acceptBtn.hidden = NO;
            }else {
                cell.acceptBtn.hidden = YES;
            }
        }
        cell.acceptBtn.tag = indexPath.section;
        [cell.acceptBtn addTarget:self action:@selector(clickCellAccept:) forControlEvents:UIControlEventTouchUpInside];
        //显示被采纳Label
        cell.cn_label.hidden =  [[dic objectForKey:@"sfcn"]isEqualToString:@"true"] ? false : true;
        //头像
        [cell.userHeadImage sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"hdrIcon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        //用户名称
        cell.userName.text = [dic objectForKey:@"hdr"];
        cell.userName.adjustsFontSizeToFitWidth = true;
        
        //回答正文
        NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 13px;font-weight:bold;width:100%%;}img{max-width:%f !important;}</style></html>", dic[@"hdfwbnr"], [UIScreen wd_screenWidth] - 150];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        cell.contentTextView.attributedText = attr;
        cell.contentTextView.numberOfLines = 0;
        cell.contentTextView.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
        [cell.contentTextView sizeToFit];
        
        //时间
        cell.time.text = [dic objectForKey:@"hdrq"];
        //TODO: - 点击回复
        cell.replyBtn.tag = indexPath.section;
        [cell.replyBtn addTarget:self action:@selector(clickCellReply:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentTextView layoutIfNeeded];

        self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] = @(CGRectGetMaxY(cell.contentTextView.frame) + 65);

        return cell;
        
    } else {
        SecondDetailCell * secondCell = [tableView dequeueReusableCellWithIdentifier:@"secondCell"];
        if (secondCell == nil) {
            secondCell = [SecondDetailCell interactionCell];
        }
        secondCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray * hfxxList = [dic objectForKey:@"hfxxList"];
        NSDictionary * secondDic = hfxxList[indexPath.row - 1];
        
        //头像
        [secondCell.image sd_setImageWithURL:[NSURL URLWithString:[secondDic objectForKey:@"hfrIcon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        
        //日期
        secondCell.time.text = [secondDic objectForKey:@"hfrq"];
        secondCell.time.adjustsFontSizeToFitWidth = true;
        
        secondCell.nameLabel.text = [secondDic objectForKey:@"hfr"];
        secondCell.nameLabel.adjustsFontSizeToFitWidth = YES;
        //正文
        secondCell.myTextView.text = [secondDic objectForKey:@"hfnr"];
        [secondCell.myTextView layoutIfNeeded];
        secondCell.bounds = CGRectMake(0, 0, [UIScreen wd_screenWidth], CGRectGetMaxY(secondCell.myTextView.frame));
        [secondCell.contentView layoutIfNeeded];
        self.cellHeightCache[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] = @(CGRectGetMaxY(secondCell.myTextView.frame) + 55);

        return secondCell;
    }
}

//回复
-(void)clickCellReply:(UIButton*)sender {
    NSDictionary * dic = dataAry[sender.tag];
    replyVc = [[InteractionReplyViewController alloc]init];
    replyVc.info = dic;
    replyVc.wtId = [self.infoDic objectForKey:@"id"];
    replyVc.view.frame = self.view.frame;
    [self.view addSubview:replyVc.view];

}
//采纳
-(void)clickCellAccept:(UIButton*)sender {
    NSDictionary * dic = dataAry[sender.tag];
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    InteractionViewController *vc = self.navigationController.viewControllers.firstObject;

    //发送采纳
    NSDictionary * httpDic = @{@"wthjID":[self.infoDic objectForKey:@"hjID"],
                               @"wtID":[self.infoDic objectForKey:@"id"],
                               @"hdID":[dic objectForKey:@"hdID"],
                               @"hdhjID":[dic objectForKey:@"hdhjID"],
                               @"hdrID":[dic objectForKey:@"hdrID"],
                               @"wtym": (vc.segment.selectedSegmentIndex == 0) ? @"sywt" : @"wdwt",
                               @"userID":teacher.teacherID,
                               @"hdzlx":dic[@"hdzlx"]};
   
    [SVProgressHUD show];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!cnwthd.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
//            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Adopted successfully", nil)];
            [self requestData];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Adoption failure", nil)];
        }
        [SVProgressHUD dismiss];
        
    }];
}

@end
