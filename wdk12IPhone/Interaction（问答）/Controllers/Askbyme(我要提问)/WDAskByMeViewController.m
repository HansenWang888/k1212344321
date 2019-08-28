//
//  WDAskByMeViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAskByMeViewController.h"
#import "WDAttachmentAlertView.h"
#import "MediaOBJ.h"
#import "WDHTTPManager.h"
#import "WDCourseDetailModel.h"
#import "WDChooseCourseView.h"

@interface WDAskByMeViewController ()<UIWebViewDelegate,WDAttachmentAlertDelegate>
@property (weak, nonatomic) IBOutlet UITableView          *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl   *segementCtrl;
@property (weak, nonatomic) IBOutlet UITextField          *textField;
@property (weak, nonatomic) IBOutlet UIWebView            *webView;
@property (weak, nonatomic) IBOutlet UIButton             *niMingBtn;
@property (strong, nonatomic) IBOutlet UIView             *footerView;
@property (strong, nonatomic) IBOutlet UIView             *headerView1;
@property (strong, nonatomic) IBOutlet UIView             *headerView2;
@property (weak, nonatomic) IBOutlet UILabel              *courseLabel;
@property (weak, nonatomic) IBOutlet UIView               *promotView;

@property (nonatomic, strong) WDAttachmentAlertView *alertView;

@property (nonatomic, strong) NSMutableArray        *courseArray;//课程数组
@property (nonatomic, strong) WDChooseCourseView    *courseView;//选择课程view
@property (nonatomic, strong) WDCourseDetailModel   *selectedModel;//已选课程的model

@property (nonatomic,assign) BOOL isHttping;

@end

@implementation WDAskByMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"我要提问", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.tableFooterView = self.footerView;
    self.headerView1.h = 64;
    self.tableView.tableHeaderView = self.headerView1;
    
    [self settings];
    [self requestForAllCourse];
}

- (IBAction)segementChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            self.tableView.tableHeaderView = self.headerView1;
        }
            break;
        case 1:
        {
            self.tableView.tableHeaderView = self.headerView2;
        }
            break;
        case 2:
        {
            self.tableView.tableHeaderView = [UIView new];
        }
            break;
        default:
            break;
    }
}

//选择课程
- (IBAction)chooseCourse:(UIButton *)sender {
    
    [self.view bringSubviewToFront:self.promotView];
    [self.view bringSubviewToFront:self.courseView];
    self.promotView.hidden = NO;
    self.courseView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.courseView.transform = CGAffineTransformIdentity;
    }];
    WEAKSELF(self);
    self.courseView.cancleBlock = ^{
        [weakSelf dismissCourseView];
    };
    self.courseView.confirmBlock = ^(WDCourseDetailModel *dModel){
        if (!dModel) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请选择课程!", nil)];
            return;
        }
        weakSelf.selectedModel = dModel;
        weakSelf.courseLabel.text = [NSString stringWithFormat:@"%@%@%@%@",dModel.km,dModel.nj,dModel.cb,dModel.jcbbmc];
        weakSelf.headerView1.h = 120;
        weakSelf.tableView.tableHeaderView = weakSelf.headerView1;
        [weakSelf dismissCourseView];
    };
    
}

- (void)dismissCourseView {
    [UIView animateWithDuration:0.3 animations:^{
        self.courseView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        self.promotView.hidden = YES;
        self.courseView.hidden = YES;
    }];
}

//匿名
- (IBAction)nimingBtnCLicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

//提交
- (IBAction)confirmClicked:(UIButton *)sender {
    if (self.isHttping) return;
    WDTeacher * teacher = [WDTeacher sharedUser];
    NSMutableDictionary *temDict = @{}.mutableCopy;
    
    [temDict setObject:teacher.teacherID forKey:@"userID"];
    [temDict setObject:teacher.userType forKey:@"yhlx"];
    

    //是否匿名
    [temDict setObject:self.niMingBtn.isSelected?@"true":@"false" forKey:@"sfnm"];

    //富文本
    NSString *taskContent = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
    NSString *str = [taskContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [str componentsSeparatedByString:@"_wd_"];
    if (array.count >= 3) {
        if (![array[0] length] && ![array[1] length] && ![array[2] length]) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入问题内容!", nil)];
            return;
        }
        [temDict setObject:array[0] forKey:@"wtfwbnr"];
        [temDict setObject:array[1] forKey:@"wtwz"];
        [temDict setObject:array[2] forKey:@"wttpList"];
    }
    
    switch (self.segementCtrl.selectedSegmentIndex) {
        case 0:
        {
            if (!self.selectedModel) {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请选择课程!", nil)];
                return;
            }
            [temDict setObject:@"1" forKey:@"wtlx"];
            [temDict setObject:self.selectedModel.kmID forKey:@"kmID"];
            [temDict setObject:self.selectedModel.njID forKey:@"njID"];
            [temDict setObject:self.selectedModel.cb forKey:@"cb"];
            [temDict setObject:self.selectedModel.jcbbmc forKey:@"bbmc"];
            [temDict setObject:self.selectedModel.jcid forKey:@"jcID"];
            [temDict setObject:self.selectedModel.jcbbid forKey:@"jcbbID"];
            [temDict setObject:@"" forKey:@"kcID"];
            [temDict setObject:@"" forKey:@"ztzt"];
            [temDict setObject:@"" forKey:@"xsz"];
        }
        break;
        case 1:
        {
            if (!self.textField.text.length) {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请输入专题标题!", nil)];
                return;
            }
            [temDict setObject:@"2" forKey:@"wtlx"];
            [temDict setObject:self.textField.text forKey:@"ztzt"];

            [temDict setObject:@"" forKey:@"kmID"];
            [temDict setObject:@"" forKey:@"njID"];
            [temDict setObject:@"" forKey:@"cb"];
            [temDict setObject:@"" forKey:@"bbmc"];
            [temDict setObject:@"" forKey:@"jcID"];
            [temDict setObject:@"" forKey:@"jcbbID"];
            [temDict setObject:@"" forKey:@"kcID"];
            [temDict setObject:@"" forKey:@"xsz"];

        }
            break;
        case 2:
        {
            [temDict setObject:@"3" forKey:@"wtlx"];
            [temDict setObject:@"" forKey:@"ztzt"];
            [temDict setObject:@"" forKey:@"kmID"];
            [temDict setObject:@"" forKey:@"njID"];
            [temDict setObject:@"" forKey:@"cb"];
            [temDict setObject:@"" forKey:@"bbmc"];
            [temDict setObject:@"" forKey:@"jcID"];
            [temDict setObject:@"" forKey:@"jcbbID"];
            [temDict setObject:@"" forKey:@"kcID"];
            [temDict setObject:@"" forKey:@"xsz"];
        }
            break;
        default:
            break;
    }
    WEAKSELF(self);
    self.isHttping  = YES;
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:temDict urlString:[NSString stringWithFormat:@"%@/wd!xjwt.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        [SVProgressHUD dismiss];
        self.isHttping  = NO;
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            //成功
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"提问成功", nil)];
            if (weakSelf.confirmSuccess) {
                weakSelf.confirmSuccess();
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"提问失败", nil)];
        }
    }];
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.1];
    }
    return true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"init()"];
    [webView stringByEvaluatingJavaScriptFromString:@"setCurrentType('2')"];
    if ([System_Language isEqualToString:@"ch"]) {
        [webView stringByEvaluatingJavaScriptFromString:@"setLanguage('ch')"];
    }else {
        [webView stringByEvaluatingJavaScriptFromString:@"setLanguage('en')"];
    }
}

- (void)selectPhotoFrom {
    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"上传附件", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"拍照", nil),NSLocalizedString(@"相册", nil),NSLocalizedString(@"手写", nil), nil];
    self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self aler:alert];
    self.alertView.attachmentDelegate = self;
    self.alertView.isWrite = YES;
    [self.alertView show];
}

#pragma mark -- WDAttachmentAlertDelegate
- (void)imageAfterDrawing:(UIImage *)image {
    if (image) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
}
- (void)attachmentWithRecordURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp3"];
}

- (void)attachmentWithPhotos:(NSArray<UIImage *> *)imgs {
    for (UIImage *image in imgs) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)attachmentWithVideoURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp4"];
}

- (void)uploadAttachmentWithData:(NSData *)data type:(NSString *)type {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在上传", nil)];
    
    MediaOBJ *obj = [MediaOBJ new];
    obj.mediaType = type;
    obj.mediaData = data;
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger] uploadWithAdjunctFileWithData:@[obj] progressBlock:nil finished:^(NSDictionary *data) {
        [SVProgressHUD dismiss];
        NSArray *array = data[@"msgObj"];
        NSDictionary *di = array.firstObject;
        NSString *str = [NSString stringWithFormat:@"appendAttachment('%@/%@')", FILE_SEVER_DOWNLOAD_URL, di[@"fileId"]];
        [weakSelf.webView stringByEvaluatingJavaScriptFromString:str];
    }];
}

#pragma mark -- 请求课程
- (void)requestForAllCourse {

    WDTeacher * teacher = [WDTeacher sharedUser];
    NSDictionary * httpDic = @{
                               @"userID":teacher.teacherID,
                               @"yhlx":teacher.userType
                               };
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!getkcxx.action",EDU_BASE_URL] finished:^(NSDictionary *dic) {
        
        NSArray *temArr = dic[@"kcxxList"];
        for (NSDictionary *item in temArr) {
            WDCourseDetailModel *model = [WDCourseDetailModel getCourseModelWith:item];
            [self.courseArray addObject:model];
        }
        self.courseView.courses = self.courseArray;
    }];
    
    
}

#pragma mark -- settings
- (void)settings {
    _courseArray = @[].mutableCopy;
    //webView
    self.webView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.webView.layer.borderWidth = 1.0;
    self.webView.layer.cornerRadius = 4.0f;
    self.webView.scrollView.showsHorizontalScrollIndicator = false;
    self.webView.scrollView.showsVerticalScrollIndicator = false;
    NSString *path = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/webapp/app/jsp/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
    
    self.courseView = [[[NSBundle mainBundle]loadNibNamed:@"WDChooseCourseView" owner:nil options:nil] lastObject];
    [self.view addSubview:self.courseView];
    self.courseView.hidden = YES;
    [self.courseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(40+64);
        make.left.offset(10);
        make.right.offset(-10);
        make.height.equalTo(@(450*([UIScreen wd_screenWidth]/375.0)));
    }];
    
    self.promotView.userInteractionEnabled = YES;
    [self.promotView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCourseView)]];
    
}
- (void)dealloc {

}
@end
