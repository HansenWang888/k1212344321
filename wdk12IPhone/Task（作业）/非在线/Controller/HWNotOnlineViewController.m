//
//  NotOnlineViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWNotOnlineViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "HWExplainTableViewHeaderView.h"
#import "HWInputScoresTableViewCell.h"
#import "ResourceVCViewController.h"
#import "HWWebViewTableViewCell.h"
#import "HWInputAccessoryCell.h"
#import "HWAnnesTableViewCell.h"
#import "HWNotOnlineRequest.h"
#import "HWNotOnlineModel.h"
#import "HWAccessoryModel.h"
#import "HWStudentTask.h"
#import "StudentModel.h"
#import "HWTaskModel.h"
#import "SDWebImageDownloader.h"
#import <WDToolsManager/WDToolsManager.h>
#import "WDShowImageController.h"

@interface HWNotOnlineViewController ()<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HWNotOnlineModel *data;
///  webCell 不重用
@property (nonatomic, strong) HWWebViewTableViewCell *webCell;
///  webView高度
@property (nonatomic, assign) CGFloat webCellHeight;
///  评分
@property (nonatomic, weak) UITextField *pf;
///  评语
@property (nonatomic, weak) UITextField *py;
///  评分和评语反馈cell
@property (nonatomic, strong) HWInputScoresTableViewCell *inputCell;
///  需要添加的附件cell
@property (nonatomic, strong) HWInputAccessoryCell *accessoryCell;
///  学生附件列表
@property (nonatomic, strong) NSMutableArray *studentAccList;

@end

@implementation HWNotOnlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
}

- (void)initView {
    self.tableView = [TPKeyboardAvoidingTableView new];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[HWAnnesTableViewCell class] forCellReuseIdentifier:@"HWAnnesTableViewCell"];
    [self.tableView registerClass:[HWWebViewTableViewCell class] forCellReuseIdentifier:@"HWWebViewTableViewCell"];
    [self.tableView registerClass:[HWInputScoresTableViewCell class] forCellReuseIdentifier:@"HWInputScoresTableViewCell"];
    [self.tableView registerClass:[HWInputAccessoryCell class] forCellReuseIdentifier:@"HWInputAccessoryCell"];
    [self.tableView registerClass:[HWExplainTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:@"HWExplainTableViewHeaderView"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.webCellHeight = 1;
    self.title = self.taskModel.zymc;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSubmit ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 3 ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) { return 0; }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.webCellHeight;
    } else if (indexPath.section == 1) {
        NSInteger col = self.data.fjList.count / 3 + (self.data.fjList.count % 3 > 0 ? 1 : 0);
        return col * 100 + ((col > 1) ? (col - 1) * 10 : 0);
    } else if (indexPath.section == 2) {
        NSInteger col = self.studentAccList.count / 3 + (self.studentAccList.count % 3 > 0 ? 1 : 0);
        return col * 100 + ((col > 1) ? (col - 1) * 10 : 0);
    } else if (indexPath.section == 3) {
        return indexPath.row == 0 ? 54 : 90;
    }
    
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) { return nil; }
    HWExplainTableViewHeaderView *hv = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HWExplainTableViewHeaderView"];
    [hv setValueForDataSource:section == 1 ? [NSString stringWithFormat:@"  %@  ", NSLocalizedString(@"作业附件", nil)] :
     ( section == 2 ? [NSString stringWithFormat:@"  %@  ", NSLocalizedString(@"学生提交答案", nil)]
      : [NSString stringWithFormat:@"  %@  ", NSLocalizedString(@"批改", nil)])];
    return hv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF(self);
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.webCell) {
            return self.webCell;
        }
        self.webCell = [self.tableView dequeueReusableCellWithIdentifier:@"HWWebViewTableViewCell" forIndexPath:indexPath];
        self.webCell.webView.delegate = self;
        return self.webCell;
    }
    if (indexPath.section == 1 || indexPath.section == 2) {
        HWAnnesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWAnnesTableViewCell" forIndexPath:indexPath];
        cell.dataSource = indexPath.section == 1 ? self.data.fjList.copy : self.studentAccList.copy;
        cell.didSel = ^(NSIndexPath *index) {
            HWAccessoryModel *model;
            if (indexPath.section == 1) { // 教师附件
               model = weakSelf.data.fjList[index.row];
                
                
                if ([WDShowImageController isImage:model.fjgs]) {
                    [self presentToPhotoBroswerVC:model.fjdz];
                }else {
                    ResourceVCViewController* vc = [[ResourceVCViewController alloc] initWithPath:model.fjdz ConverPath:model.fjzmdz Type:model.fjgs Name:model.fjmc];
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
                }
                
                return ;
            } else { // 学生附件
                model = weakSelf.studentAccList[index.row];
            }
            NSString *type = model.fjgs;
            if (type.length && ([type isEqualToString:@"PNG"] || [type isEqualToString:@"JPEG"] || [type isEqualToString:@"GIF"] || [type isEqualToString:@"JPG"] || [type isEqualToString:@"BMP"] || [type isEqualToString:@"GPEG"])) {
                NSString *imageUrl = model.fjdz;
                [SVProgressHUD show];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        if (image) {
                            WDDelineateVC *delineVC = [WDDelineateVC delineateVeticalVCWithImage:image];
                            __weak typeof(delineVC) deline = delineVC;
                            
                            delineVC.finishedBlock = ^(UIImage *imageB,WDDelineateVC *vc) {
                                [weakSelf.accessoryCell addImage:imageB];
                                [deline dismissViewControllerAnimated:YES completion:nil];
                            };
                            [weakSelf presentViewController:delineVC animated:YES completion:nil];
                        }
                    });
                }];
            }else {
                
                if ([WDShowImageController isImage:model.fjgs]) {
                    [self presentToPhotoBroswerVC:model.fjdz];
                }else {
                    ResourceVCViewController* vc = [[ResourceVCViewController alloc] initWithPath:model.fjdz ConverPath:model.fjzmdz Type:model.fjgs Name:model.fjmc];
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
                }
            }
        };
        return cell;
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            if (self.inputCell) { return self.inputCell; }
            self.inputCell = [self.tableView dequeueReusableCellWithIdentifier:@"HWInputScoresTableViewCell" forIndexPath:indexPath];
            [self.inputCell.feedbackButton addTarget:self action:@selector(submitNotOnLineTaskFeedbackAction) forControlEvents:UIControlEventTouchUpInside];
            return self.inputCell;
        } else {
            if (self.accessoryCell) { return self.accessoryCell; }
            self.accessoryCell = [self.tableView dequeueReusableCellWithIdentifier:@"HWInputAccessoryCell" forIndexPath:indexPath];
            self.accessoryCell.superViewController = self;
            return self.accessoryCell;
        }
    }
    return [UITableViewCell new];
}

- (void)presentToPhotoBroswerVC:(NSString *)imageUrl {
    if (![imageUrl hasPrefix:@"http"]) {
        imageUrl =  [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL,imageUrl];
    }
    UIViewController *vc = [WDShowImageController initImageVC:@"" imageUrlArray:@[imageUrl] index:0];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadData {
    WEAKSELF(self);
    [HWNotOnlineRequest getNotOnlineTaskDetailWith:self.taskModel.zyID handler:^(HWNotOnlineModel *data) {
        weakSelf.data = data;
        [weakSelf.tableView reloadData];
        [weakSelf loadWebView];
    }];
}

///  加载webView
- (void)loadWebView {
    NSMutableString *strM = [NSMutableString stringWithString:@"<html><head></head><body>"];
    if (self.data.zynr) {
        [strM appendString:self.data.zynr];
    }
    [strM appendString:@"</body><script>function checkImage(img) {"
     "window.location.href = 'wd:checkImage:&' + img.src;"
     "}</script></html>"];
    [strM appendString:[NSString stringWithFormat:@"<style>body,html{width:100%%;}img{max-width:%f !important;}</style>", [UIScreen wd_screenWidth] - 20]];
    [self.webCell.webView loadHTMLString:strM baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webCellHeight = webView.scrollView.contentSize.height;
    [self.tableView reloadData];
}

///  提交非在线作业方法
- (void)submitNotOnLineTaskFeedbackAction {
    if (!self.isSubmit) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"该同学未提交作业,不能批改", nil)]; return ; }
    if ([self.inputCell.gradeTextField.text isEqualToString:@""] && [self.inputCell.evaluateTextField.text isEqualToString:@""] && self.accessoryCell.data.count == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入分数或评语、附件", nil)];
        return ;
    }
//    if ([self.inputCell.evaluateTextField.text isEqualToString:@""] || (self.inputCell.evaluateTextField.text == nil)) {
//        [SVProgressHUD showSuccessWithStatus:@"请输入评价"]; return ; }
    WEAKSELF(self);
    NSString *pf = [NSString stringWithFormat:@"%.2f", [self.inputCell.gradeTextField.text floatValue]];
//    if ([self.inputCell.gradeTextField.text floatValue] > 100.0 || [self.inputCell.gradeTextField.text floatValue] < 0) {
//        [SVProgressHUD showErrorWithStatus:@"得分输入有误，请输入0-100以内的分数"];
//        return ;
//    }
    [HWNotOnlineRequest submitTaskWith:self.studentModel.id taskId:self.taskModel.zyID zypf:pf zypy:self.inputCell.evaluateTextField.text fjList:self.accessoryCell.data handler:^(BOOL isSucceess) {
        if (isSucceess) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改成功", nil)];
            weakSelf.studentTask.pf = pf;
            weakSelf.studentTask.py = weakSelf.inputCell.evaluateTextField.text;
            weakSelf.studentTask.jsfjList = weakSelf.accessoryCell.data;

            if (weakSelf.correctFinish && ![weakSelf.studentTask.zt isEqualToString:@"2"]) {
                weakSelf.correctFinish(weakSelf.studentModel);
            }
            weakSelf.studentTask.zt = @"2";
        } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改失败,请稍候重试", nil)];
        }
    }];
}

- (void)setStudentTask:(HWStudentTask *)studentTask {
    _studentTask = studentTask;
    self.studentAccList = self.studentTask.fjList;
}

- (void)setAccessoryCell:(HWInputAccessoryCell *)accessoryCell {
    _accessoryCell = accessoryCell;
    if (self.studentTask.jsfjList.count > 0) {
        accessoryCell.data = self.studentTask.jsfjList;
    }
}

- (void)setInputCell:(HWInputScoresTableViewCell *)inputCell {
    _inputCell = inputCell;
    if (self.studentTask) {
        if ([self.studentTask.zt isEqualToString:@"2"]) { // 已反馈
            self.inputCell.gradeTextField.text = [NSString stringWithFormat:@"%@", self.studentTask.pf];
            self.inputCell.evaluateTextField.text = [NSString stringWithFormat:@"%@", self.studentTask.py];
        }
    }
}

- (NSMutableArray *)studentAccList {
    if (!_studentAccList) {
        _studentAccList = [NSMutableArray array];
    }
    return _studentAccList;
}

@end
