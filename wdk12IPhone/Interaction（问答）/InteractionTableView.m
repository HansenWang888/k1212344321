//
//  InteractionTableView.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "InteractionTableView.h"
#import "InteractionCell.h"
#import "ExpandTableViewCell.h"
#import "WDHTTPManager.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface InteractionTableView ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * dataAry;
    
    NSString * allQuestionEndId;
    NSString * myQuestionEndId;
    
    NSMutableArray * allQuestionAry;
    NSMutableArray * myQuestionAry;
    
    //当前状态 1所有问题 2我的提问
    int questionType;
}
///  所有问题
@property (nonatomic, strong) NSMutableArray *allQuestionArray;
///  我的问题
@property (nonatomic, strong) NSMutableArray *myQuestionArray;

@end
@implementation InteractionTableView

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        self.dataSource = self;
        self.delegate = self;
//        self.rowHeight = 96;
        
        allQuestionEndId = @"";
        myQuestionEndId = @"";
        questionType = 1;
        [self requestDataWithAllQuestion];
        
        
        //设置上下拉刷新
        MJRefreshGifHeader * header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadUp)];
        self.mj_header = header;
        
        MJRefreshAutoGifFooter * foot = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDown)];
        self.mj_footer = foot;
        
        //监听 所有问题 和 我的提问 按钮点击
        [self addObserver:self forKeyPath:@"questionType" options:NSKeyValueObservingOptionInitial context:nil];
        
        //监听发布问题成功 然后刷新列表
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestList) name:@"questionOk" object:nil];
    }
    return  self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"questionType"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.questionType == 1) {
        //所有问题
        if (!self.allQuestionArray) {
            [self requestDataWithAllQuestion];
        } else {
            dataAry = self.allQuestionArray;
            [self reloadData];
        }
        
        questionType = 1;
        
    }else if (self.questionType == 2){
        //我的提问
        if (!self.myQuestionArray) {
            [self requetDataWithMyQuestion];
        } else {
            dataAry = self.myQuestionArray;
            [self reloadData];
        }
        questionType = 2;
    }
}
-(void)requestList
{
//    if (questionType == 1) {
        allQuestionEndId = @"";
        [self requestDataWithAllQuestion];
//    }else if (questionType == 2){
        myQuestionEndId = @"";
        [self requetDataWithMyQuestion];
//    }
}
-(void) requetDataWithMyQuestion
{

    WDTeacher * teacher = [WDTeacher sharedUser];
    
    NSDictionary * httpDic = @{@"xxID":teacher.schoolID,
                               @"userID":teacher.teacherID,
                               @"startID":myQuestionEndId,
                               @"ts":@"5",
                               @"yhlx":teacher.userType};
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wdv1!getWDWTLIST.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
        if ([myQuestionEndId isEqualToString:@""]) {
            myQuestionAry = [[NSMutableArray alloc]init];
        }
        
        [SVProgressHUD dismiss];
        myQuestionEndId = [dic objectForKey:@"endID"];
        
        //加数据
        NSArray * justAry = [dic objectForKey:@"wtList"];
        for (NSDictionary * dd in justAry) {
             [myQuestionAry addObject:dd];
        }
        
        dataAry = myQuestionAry;
        self.myQuestionArray = dataAry;
        [self reloadData];
        
//        NSLog(@"%@",dic);
        
    }];
    
}
-(void)requestDataWithAllQuestion
{
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    NSDictionary * httpDic = @{@"xxID":teacher.schoolID,
                               @"startID":allQuestionEndId,
                               @"ts":@"5",
                               @"yhlx":teacher.userType};
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wdv1!getSYWTLIST.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
        if ([allQuestionEndId isEqualToString:@""]) {
            allQuestionAry = [[NSMutableArray alloc]init];
        }
        
        [SVProgressHUD dismiss];
        allQuestionEndId = [dic objectForKey:@"endID"];
        
        //加数据
        NSArray * justAry = [dic objectForKey:@"wtList"];
        for (NSDictionary * dic in justAry) {
            [allQuestionAry addObject:dic];
        }
        
        dataAry = allQuestionAry;
        self.allQuestionArray = dataAry;
        
        [self reloadData];
    }];
}


#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = dataAry[indexPath.row];
    //被采纳回答数组
    NSArray * expandAry = [dic objectForKey:@"cnList"];
    if (expandAry.count != 0){
        //有扩展状态
        
        //TODO 算高度
        NSDictionary * expandDic = expandAry[0];
        NSString * justText = [expandDic objectForKey:@"hdwz"];
        
        //通过计算左右间隔算出textView的宽度
        int textViewWidth = SCREEN_WIDTH - (16+89);
        
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
//        NSLog(@"%@", NSStringFromCGRect([justText boundingRectWithSize:CGSizeMake(textViewWidth, 3000)  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil]));
        CGSize textViewSize = [justText boundingRectWithSize:CGSizeMake(textViewWidth, 3000)  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        
        if (textViewSize.height + 14 < 65) {
            return 204;
        }else{
            return 204 + ((textViewSize.height + 26) -65);
        }

    }else{
        return 96+10;
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{

    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary * dic = dataAry[indexPath.row];
    
    //被采纳回答数组
    NSArray * expandAry = [dic objectForKey:@"cnList"];
    
    
    if (expandAry.count != 0) {
        //有扩展状态
        ExpandTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"expandCell"];
        if (cell == nil) {
            cell = [ExpandTableViewCell interactionCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        NSLog(@" -- %@",NSStringFromCGRect(cell.expandTextView.frame));
        
        //回答人数
        NSInteger numOf = [dic[@"hds"] integerValue];
        cell.answerNum.text = [NSString stringWithFormat:@"有%ld个回答",numOf];
        
        
        //头像
        if ([dic[@"sfnm"] isEqualToString:@"false"]) {
            [cell.headPortrait sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        } else {
            cell.headPortrait.image = [UIImage imageNamed:@"default_touxiang"];
        }
        
        //名字
        cell.name.text = [dic[@"sfnm"] isEqualToString:@"false"] ? dic[@"twr"] : NSLocalizedString(@"Anonymous", nil);
        cell.name.adjustsFontSizeToFitWidth = true;
        //标题
        NSString *titleStr = [dic[@"wtlx"] isEqualToString:@"2"] ? dic[@"ztzt"] : dic[@"wtwz"];
        if (!titleStr || !titleStr.length) {
            titleStr = @"图片问题";
        }
        NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 13px;font-weight:bold;width:100%%;}img{max-width:%f !important;}</style></html>", titleStr, [UIScreen wd_screenWidth] - 150];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        cell.myTitle.attributedText = attr;
        cell.myTitle.numberOfLines = 2;
        cell.myTitle.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
        //时间
        cell.myTime.text = [dic objectForKey:@"twrq"];
        
        //课程描述
        cell.myDescribe.text = [NSString stringWithFormat:@"%@%@%@", [dic objectForKey:@"km"],[dic objectForKey:@"nj"],[dic objectForKey:@"cb"]];
        
        //问题类型
        NSString * wtlx;
        if ([[dic objectForKey:@"wtlx"] isEqualToString:@"1"]) {
            wtlx = NSLocalizedString(@"Course Questions", nil);
        }else if ([[dic objectForKey:@"wtlx"] isEqualToString:@"2"]){
            wtlx = NSLocalizedString(@"Seminar", nil);
        }else if ([[dic objectForKey:@"wtlx"] isEqualToString:@"3"]){
            wtlx = NSLocalizedString(@"Other problems", nil);
        }
        cell.myType.text = wtlx;
        
        //扩展部分－－－－－－－－－－－－－－－－－－－－－－－－－－
        NSDictionary * expandDic = expandAry[0];
        
        //头像
//        if ([expandDic[@"sfnm"] isEqualToString:@"false"]) {
            [cell.expandHeadPortrait sd_setImageWithURL:[NSURL URLWithString:[expandDic objectForKey:@"hdrIcon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
//        } else {
//            cell.expandHeadPortrait.image = [UIImage imageNamed:@"default_touxiang"];
//        }
        
        //名字
        cell.expandName.text = [expandDic objectForKey:@"hdr"];
        cell.expandName.adjustsFontSizeToFitWidth = true;
        //是否采纳
        if ([[expandDic objectForKey:@"sfcn"] isEqualToString:@"true"]) {
            cell.isAccept.text = NSLocalizedString(@"Has been adopted", nil);
        }else{
            cell.isAccept.text = NSLocalizedString(@"Not adopted", nil);
        }
        
        //正文
        cell.expandTextView.text = [expandDic objectForKey:@"hdwz"];
        
        //时间
        cell.expandTime.text = [expandDic objectForKey:@"hdrq"];
        
        //时间
        cell.myTime.text = [dic objectForKey:@"twrq"];
        
        
        return cell;
    }else{
        //没有扩展的状态
        
        InteractionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"interactionCell"];
        if (cell == nil) {
            
            cell = [InteractionCell interactionCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //头像
        if ([dic[@"sfnm"] isEqualToString:@"false"]) {
            [cell.headPortrait sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        } else {
            cell.headPortrait.image = [UIImage imageNamed:@"default_touxiang"];
        }
        
        //回答人数
        NSInteger numOf = [dic[@"hds"] integerValue];
        cell.answerNum.text = [NSString stringWithFormat:@"有%ld个回答",numOf];
        
        //标题
        NSString *titleStr = [dic[@"wtlx"] isEqualToString:@"2"] ? dic[@"ztzt"] : dic[@"wtwz"];
        if (!titleStr || !titleStr.length) {
            titleStr = @"图片问题";
        }
        NSString *str1 = [NSString stringWithFormat:@"%@%@%@", @"<html><body>", titleStr, @"</body><style>body{font-size: 13px;font-weight:bold}</style></html>"];
        NSAttributedString *attr1 = [[NSAttributedString alloc] initWithData:[str1 dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        cell.myTitle.attributedText = attr1;
        cell.myTitle.numberOfLines = 2;
        cell.myTitle.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
        //名字
        cell.name.text = [dic[@"sfnm"] isEqualToString:@"false"] ? [dic objectForKey:@"twr"] : NSLocalizedString(@"Anonymous", nil);
        cell.name.adjustsFontSizeToFitWidth = true;
        cell.myTime.text = [dic objectForKey:@"twrq"];

        
        //课程描述
        cell.myDescribe.text = [NSString stringWithFormat:@"%@%@%@", [dic objectForKey:@"km"],[dic objectForKey:@"nj"],[dic objectForKey:@"cb"]];
        
        //问题类型
        NSString * wtlx;
        if ([[dic objectForKey:@"wtlx"] isEqualToString:@"1"]) {
            wtlx = NSLocalizedString(@"Course Questions", nil);
        }else if ([[dic objectForKey:@"wtlx"] isEqualToString:@"2"]){
            wtlx = NSLocalizedString(@"Seminar", nil);
        }else if ([[dic objectForKey:@"wtlx"] isEqualToString:@"3"]){
            wtlx = NSLocalizedString(@"Other problems", nil);
        }
        cell.myType.text = wtlx;
        
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = dataAry[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"interctionPush" object:dic];
}

#pragma mark tableView的上下拉刷新
-(void)loadUp
{
    if (questionType == 1) {
        //所有问题
        allQuestionEndId = @"";
        [self.mj_header endRefreshing];
        [self requestDataWithAllQuestion];
    }else if (questionType == 2){
        //我的提问
        myQuestionEndId = @"";
        [self.mj_header endRefreshing];
        [self requetDataWithMyQuestion];
    }
  
}

-(void)loadDown
{
    if (questionType == 1) {
        
        [self.mj_footer endRefreshing];
        if ([allQuestionEndId isEqualToString:@""]) {
//            NSLog(@"没有更多数据了！");
            return ;
        }
        
        [self requestDataWithAllQuestion];
    
    }else if (questionType == 2){
        
        [self.mj_footer endRefreshing];
        if ([myQuestionEndId isEqualToString:@""]) {
//            NSLog(@"没有更多数据了！");
            return ;
        }
        
        [self requetDataWithMyQuestion];
    }
}
//右滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (questionType == 2) {
        return YES;
    }
    
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        WDTeacher * teacher = [WDTeacher sharedUser];
        NSDictionary * selectedDic = dataAry[indexPath.row];

        NSDictionary * httpDic = @{@"wthjID":[selectedDic objectForKey:@"hjID"],
                                   @"userID":teacher.teacherID,
                                   @"yhlx":teacher.userType};
        
        
        [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!deletewt.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
            
            if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
                //成功
                [dataAry removeObject:selectedDic];
                if (questionType == 1) { // 所有问题
                    self.allQuestionArray = dataAry;
                } else { // 我的问题
                    self.myQuestionArray = dataAry;
                }
                [self reloadData];
            }else{
                //失败
            }
        }];
        
    }

}
@end
