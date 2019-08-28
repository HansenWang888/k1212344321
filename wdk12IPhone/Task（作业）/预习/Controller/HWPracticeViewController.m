//
//  HWPracticeViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPracticeViewController.h"
#import "HomeworkTaskInfoVC.h"
#import "WDHTTPManager.h"

@interface HWPracticeViewController ()

@property (nonatomic, strong) HomeworkTaskInfoVC *taskvc;
///  提示label
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation HWPracticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    self.promptLabel = [UILabel labelBackgroundColor:nil textColor:nil font:[UIFont systemFontOfSize:15] alpha:1];
    [self.view addSubview:self.promptLabel];
    self.promptLabel.text = NSLocalizedString(@"没有更多内容了", nil);
    self.promptLabel.alpha = 0;
    [self.promptLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.view size:CGSizeZero offset:CGPointZero];
}

- (void)setStudentId:(NSString *)studentId {
    _studentId = studentId;
    [self fetchPublicBasePracticeWith:self.testId withId:self.studentId];
}

///  获取基础练习id
- (void)fetchPublicBasePracticeWith:(NSString *)ID withId:(NSString *)studentId {
    WEAKSELF(self);
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/kc!getSTXX.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"yxxxID" : ID, @"userID" : studentId ? studentId : @""} urlString:url finished:^(NSDictionary *dict) {
        [SVProgressHUD dismiss];
        if (dict != nil ) {
            if ([dict[@"stList"] count] > 0) {
                weakSelf.taskvc = [HomeworkTaskInfoVC taskInfoWithList:dict[@"stList"] with:true isSubmit:weakSelf.isSubmit];
                [weakSelf.view addSubview:self.taskvc.view];
                [weakSelf.taskvc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.bottom.equalTo(self.view);
                }];
                return ;
            } else {
                weakSelf.promptLabel.alpha = 1;
            }
        }
    }];
}

@end
