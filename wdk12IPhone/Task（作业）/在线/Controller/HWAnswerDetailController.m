//
//  HWAnswerDetailController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/18.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWAnswerDetailController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "HWSingleTestAnswerCell.h"
#import "HWOnlieStudentCell.h"
#import "HWOnlineRequest.h"
#import "StudentModel.h"
#import "HWTaskModel.h"

@interface HWAnswerDetailController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

///  底部view
@property (nonatomic, strong) UIView *bottomView;
///  输入得分
@property (nonatomic, strong) UITextField *textField;
///  评分
@property (nonatomic, strong) UIButton *gradeButton;
///  学生模型
@property (nonatomic, strong) StudentModel *student;

@property (nonatomic, copy) NSString *sjId;
@property (nonatomic, copy) NSString *stId;
@property (nonatomic, copy) NSString *xtId;
///  答案
@property (nonatomic, strong) NSDictionary *answerDict;

@property (nonatomic, assign) BOOL isAnswer;

@end

@implementation HWAnswerDetailController

- (void)loadView {
    self.view = [TPKeyboardAvoidingScrollView new];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.contentInset = UIEdgeInsetsZero;
    scrollView.contentSize = CGSizeMake([UIScreen wd_screenWidth], [UIScreen wd_screenHeight] - 64);
    scrollView.scrollEnabled = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initAutoLayout];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[HWOnlieStudentCell class] forCellReuseIdentifier:@"HWOnlieStudentCell"];
    [self.tableView registerClass:[HWSingleTestAnswerCell class] forCellReuseIdentifier:@"HWSingleTestAnswerCell"];
    
    self.bottomView = [UIView viewWithBackground:[UIColor hex:0xF4F4F4 alpha:1.0] alpha:1.0];
    self.textField = [UITextField textFieldBackgroundColor:[UIColor whiteColor] placeholder:self.isAnswer ?  NSLocalizedString(@"请输入得分", nil) :NSLocalizedString(@"该学生未作答,此题不能批改", nil)  keyboardType:UIKeyboardTypeDecimalPad];
    self.textField.userInteractionEnabled = self.isAnswer ?  true : false;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    self.gradeButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"评分", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x2F9B8C alpha:1.0]];
    self.gradeButton.layer.cornerRadius = 3;
    [self.gradeButton addTarget:self action:@selector(correctTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.textField];
    [self.bottomView addSubview:self.gradeButton];
}

///  批改作业方法
- (void)correctTaskAction {
    WEAKSELF(self);    
    [HWOnlineRequest onlineTaskScoreWith:self.student.id fbdxId:self.taskModel.fbdxID zyId:self.taskModel.zyID sjId:self.sjId stId:self.stId xtId:self.xtId stpf:self.textField.text handler:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改成功", nil)];
            NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary: weakSelf.answerDict];
            dictM[@"df"] = weakSelf.textField.text;
            weakSelf.answerDict = dictM;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            if (weakSelf.gradeContent) {
                weakSelf.gradeContent(weakSelf.answerDict);
            }
            [weakSelf.navigationController popViewControllerAnimated:true];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"批改失败", nil)];
        }
    }];
}


- (void)setValueForDataSourceWith:(NSString *)sjId type:(BOOL)type student:(StudentModel *)student stId:(NSString *)stId xtId:(NSString *)xtId {
    self.student = student;
    self.sjId = sjId;
    self.xtId = xtId;
    self.stId = stId;
    self.isAnswer = false;
    if (type) { // 小题
        for (NSDictionary *item in student.snwerArray) {
            if ([xtId isEqualToString:item[@"xtID"]]) {
                self.answerDict = item;
                self.isAnswer = true;
                break;
            }
        }
    } else { // 普通题
        for (NSDictionary *item in student.snwerArray) {
            if ([stId isEqualToString:item[@"stID"]]) {
                self.answerDict = item;
                self.isAnswer = true;
                break;
            }
        }
    }
    [self.tableView reloadData];
}

///  初始化布局
- (void)initAutoLayout {

    self.tableView.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth], [UIScreen wd_screenHeight] - 114);
    self.bottomView.frame = CGRectMake(0, [UIScreen wd_screenHeight] - 114, [UIScreen wd_screenWidth], 50);
    [self.textField zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.bottomView size:CGSizeMake([UIScreen wd_screenWidth] - 100, 30) offset:CGPointMake(10, -10)];
    [self.gradeButton zk_AlignInner:ZK_AlignTypeBottomRight referView:self.bottomView size:CGSizeMake(70, 30) offset:CGPointMake(-10, -10)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HWOnlieStudentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWOnlieStudentCell" forIndexPath:indexPath];
        cell.taskModel = self.taskModel;
        [cell setValueForDataSource:self.student];
        cell.numLabel.text = [NSString stringWithFormat:@"%ld", [self.answerDict[@"df"] integerValue]];
        return cell;
    } else if (indexPath.row == 1) {
        HWSingleTestAnswerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWSingleTestAnswerCell" forIndexPath:indexPath];
        if (self.answerDict) {
            NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 16px;color:#000000; width:100%%;}img{max-width:%f !important;}</style></html>", self.answerDict[@"daannr"] ?  self.answerDict[@"daannr"] : @"", [UIScreen wd_screenWidth] - 20];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            cell.contentLabel.attributedText = attr;
            cell.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
            cell.contentLabel.numberOfLines = 0;
//            [cell.contentLabel layoutIfNeeded];
//            [cell.contentView layoutIfNeeded];
        }
        return cell;
    }
    return [UITableViewCell new];
}

@end
