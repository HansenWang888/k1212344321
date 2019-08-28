//
//  HWClassesScanVC.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesScanVC.h"
#import "HWClassesBillView.h"
#import "HWClassesChoiceView.h"
#import "HWClassesTabView.h"
#import "WDHTTPManager.h"
#import "HWClassesStudentList.h"
@interface HWClassesScanVC ()<HWClassesTabViewDelegate>
@property (nonatomic, strong) HWClassesBillView *billView;
@property (nonatomic, strong) HWClassesChoiceView *choiceView;
@property (nonatomic, strong) HWClassesTabView *tabView;
@property (nonatomic, strong) NSMutableArray *studentList;//未扫描
@property (nonatomic, copy) NSString *currentBjID;


@end

@implementation HWClassesScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubView];

}
+ (instancetype)classesScanWithBjID:(NSString *)bjID {
    HWClassesScanVC *vc = [HWClassesScanVC new];
    [vc loadDataWithBjID:bjID];
    vc.currentBjID = bjID;
    return vc;
}
- (void)hideSubmitButton {
    [self.tabView hideSubmitButton];
    [self.billView onlyShowScanedTable];
}
- (void)setupSubView {
    [self.view addSubview:self.billView];
    [self.billView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.left.right.offset(0);
        make.height.offset(200);
    }];
    [self.view addSubview:self.choiceView];
    [self.choiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(self.billView.mas_bottom).offset(5);
        make.height.offset(25);
    }];
    [self.view addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.offset(100);
    }];
    self.tabView.delegate = self;
}
- (void)loadDataWithBjID:(NSString *)bjID {
    [SVProgressHUD showWithStatus:nil];
    NSString *url = [NSString stringWithFormat:@"%@getBJXSKPGLList?",UNIFIED_USER_KTLX_URL];
    NSDictionary *dict = @{@"jszh":[WDUser sharedUser].loginID,@"userType":[WDUser sharedUser].userType,@"bjID":bjID};
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:dict urlString:url finished:^(NSDictionary *response) {
        if (response) {
            [SVProgressHUD dismiss];
            self.studentList = @[].mutableCopy;
            NSArray *xskpList = response[@"data"][@"xskpList"];
            for (NSDictionary *dict in xskpList) {
                [self.studentList addObject:[HWClassesStudentList classesStudentListWithDict:dict]];
            }
            [self.billView showDataWithStudentList:self.studentList.copy];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"加载失败！", nil)];
        }
    }];
}
-(void)onBoradsOut:(NSArray*)boards {
    if (boards.count == 0) {
        return;
    }
    NSArray *students = [self.billView showScanedStudentList:boards];
    if (students) {
        [self.choiceView showScanedDataWithStudents:students];
    }
}

#pragma mark - HWClassesTabViewDelegate
- (void)classesTabResetButtonClick {
    [self.billView resetData];
    [self.choiceView resetData];
}
- (void)classesTabBackButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)classesTabSubmitButtonClickWithStudentList:(NSArray *)list {
    NSArray *array = [self.billView getScanedStudents];
    if (array.count == 0) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"没有可提交的数据！", nil)];
    } else {
        //提交扫描数据
        [SVProgressHUD showWithStatus:NSLocalizedString(@"提交中...", nil)];
        NSString *url = [NSString stringWithFormat:@"%@postKTLXInfo",UNIFIED_USER_KTLX_URL];
         NSMutableArray *lxList = @[].mutableCopy;
        [array enumerateObjectsUsingBlock:^(HWClassesStudentList *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [lxList addObject:@{@"daan":obj.selectedContent,@"kpbh":obj.kpbh,@"xsID":obj.xsID}];
        }];
        NSString *content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:lxList.copy options:0 error:0] encoding:NSUTF8StringEncoding];
        NSDictionary *dict = @{@"jszh":[WDUser sharedUser].loginID,@"userType":[WDUser sharedUser].userType,@"bjID":self.currentBjID,@"ktlxList":content};
        [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:dict urlString:url finished:^(NSDictionary *response) {
            if ([response[@"succflag"] boolValue]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"提交成功！", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"提交失败！", nil)];
            }
        }];

    }
}
- (HWClassesBillView *)billView {
    if (!_billView) {
        _billView = [HWClassesBillView classesBillView];
    }
    return _billView;
}
- (HWClassesChoiceView *)choiceView {
    if (!_choiceView) {
        _choiceView = [HWClassesChoiceView new];
        _choiceView.backgroundColor = [UIColor clearColor];
    }
    return _choiceView;
}
- (HWClassesTabView *)tabView {
    if (!_tabView) {
        _tabView = [HWClassesTabView classesTabView];
    }
    return _tabView;
}
- (void)dealloc {
    NSLog(@"scanVC---8888");

}
@end
