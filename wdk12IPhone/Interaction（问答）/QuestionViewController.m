//
//  QuestionViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/5.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "QuestionViewController.h"
#import "WDHTTPManager.h"
#import "SeleedViewController.h"
#import "ZYQAssetPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "WDAttachmentAlertView.h"
#import "MediaOBJ.h"

@interface QuestionViewController ()<seleedViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UIAlertViewDelegate, WDAttachmentAlertDelegate> {
    NSArray * updatePictures;
    SeleedViewController * seleedView;
    NSMutableArray * selectedImageMary; //选择相片保存的数组
    NSString * my_wtlx;//记录当前的问题类型
    NSDictionary * selectedClassDic; //选中的课程信息
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmented;

@property (strong, nonatomic) IBOutlet UIView *classTopView;
@property (strong, nonatomic) IBOutlet UIView *specialTopView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *myContentView;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *classLabelHeight;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *courseHeight;
@property (weak, nonatomic) IBOutlet UIButton *anonymity_btn;
@property (weak, nonatomic) IBOutlet UITextField *myTitleTextField;

@property (nonatomic, strong) WDAttachmentAlertView *alertView;
///  是否正在提交
@property (nonatomic, assign) BOOL isSubmit;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    self.title = NSLocalizedString(@"I have a question", nil);
    self.mySegmented.tintColor = [UIColor colorWithRed:57/255.0 green:235/255.0 blue:207/255.0 alpha:1.0];
    [self.mySegmented addTarget:self action:@selector(clickSegmented) forControlEvents:UIControlEventValueChanged];
    my_wtlx = @"1";
    //textView的边框
    self.webView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.webView.layer.borderWidth = 1.0;
    self.webView.layer.cornerRadius = 4.0f;
    self.webView.scrollView.showsHorizontalScrollIndicator = false;
    self.webView.scrollView.showsVerticalScrollIndicator = false;
    
    selectedImageMary = [[NSMutableArray alloc]init];
    self.courseHeight.constant = 0;
    self.classLabelHeight.constant = 0;
    CGRect frame = self.classTopView.frame;
    frame.size.height = 61;
    self.classTopView.frame = frame;
    self.myTableView.tableHeaderView = self.classTopView;
    self.webView.delegate = self;
    NSString *path = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/webapp/app/jsp/index.html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.1];
    }
    return true;
}

///  选择照片来源
- (void)selectPhotoFrom {
    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Attachment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"Take pictures", nil),NSLocalizedString(@"Album", nil),NSLocalizedString(@"手写", nil), nil];
    self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self aler:alert];
    self.alertView.attachmentDelegate = self;
    self.alertView.isWrite = YES;
    [self.alertView show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"init()"];
    [webView stringByEvaluatingJavaScriptFromString:@"setCurrentType('2')"];
}

//MARK:WDAttachmentAlertDelegate
- (void)imageAfterDrawing:(UIImage *)image {
    if (image) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
}
- (void)attachmentWithRecordURL:(NSURL *)url {
    //上传。。。
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp3"];
}

- (void)attachmentWithPhotos:(NSArray<UIImage *> *)imgs {
    //上传。。。
    for (UIImage *image in imgs) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)attachmentWithVideoURL:(NSURL *)url {
    //上传。。。
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp4"];
}

- (void)uploadAttachmentWithData:(NSData *)data type:(NSString *)type {
    [SVProgressHUD showWithStatus:@"正在上传"];
    
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

#pragma mark - clickSomeThing
- (IBAction)clickSelectedCourse:(id)sender {
    
    WDTeacher * teacher = [WDTeacher sharedUser];
    NSDictionary * httpDic = @{@"userID":teacher.teacherID,
                               @"yhlx":teacher.userType};
    [SVProgressHUD show];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!getkcxx.action",EDU_BASE_URL] finished:^(NSDictionary *dic) {
        [SVProgressHUD dismiss];
        //显示提示框
        seleedView = [[SeleedViewController alloc]init];
        seleedView.view.frame = self.view.frame;
        seleedView.title_label.text = NSLocalizedString(@"Please select courses", nil);
        seleedView.type = 3;
        seleedView.delegate = self;
        [seleedView beginMySelfWithData:[dic objectForKey:@"kcxxList"]];
        [self.view addSubview:seleedView.view];
    }];
}

- (void)clickSegmented {
    ///   1课程疑问 2专题讨论 3其他问题
    self.myTableView.tableHeaderView = self.mySegmented.selectedSegmentIndex == 0 ? self.classTopView : (self.mySegmented.selectedSegmentIndex == 1 ? self.specialTopView : nil);
    my_wtlx = self.mySegmented.selectedSegmentIndex == 0 ? @"1" : (self.mySegmented.selectedSegmentIndex == 1 ? @"2" : @"3");
}

- (IBAction)clickAnonymity:(UIButton*)sender {
    sender.selected = !sender.selected;
}

- (IBAction)clickConfirm:(id)sender {
    //判断是否有未选择项
    if (!selectedClassDic && [my_wtlx isEqualToString:@"1"]) { [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"No courses selected!", nil)]; return; }
    [self requestConfirm];
}

-(void)requestConfirm {
    if (self.isSubmit) {
        return ;
    }
    NSDictionary * httpDic;
    //是否匿名
    NSString * httpNiMing;
    if (self.anonymity_btn.selected) {
        httpNiMing = @"true";
    }else{
        httpNiMing = @"false";
    }
    
    NSString *taskContent = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
    NSString *str = [taskContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [str componentsSeparatedByString:@"_wd_"];
    
    WDTeacher * teacher = [WDTeacher sharedUser];
    if ([my_wtlx isEqualToString:@"1"]) {

        //课程疑问
        httpDic = @{@"wtlx":my_wtlx,
                    @"kcID":@"",
                    @"kmID":selectedClassDic[@"kmID"],
                    @"njID":selectedClassDic[@"njID"],
                    @"cb":selectedClassDic[@"cb"],
                    @"bbmc":selectedClassDic[@"jcbbmc"],
                    @"jcID":selectedClassDic[@"jcid"],
                    @"jcbbID":selectedClassDic[@"jcbbid"],
                    @"ztzt":@"",
                    @"wtfwbnr" : array[0],
                    @"wtwz": array[1],
                    @"wttpList":array[2],
                    @"sfnm":httpNiMing,
                    @"xsz" : @"",
                    @"userID":teacher.teacherID,
                    @"yhlx":teacher.userType};
        
    }else if ([my_wtlx isEqualToString:@"2"]){
        //专题讨论
        httpDic = @{@"wtlx":my_wtlx,
                    @"kcID":@"",
                    @"kmID":@"",
                    @"njID":@"",
                    @"cb"  : @"",
                    @"bbmc": @"",
                    @"jcID": @"",
                    @"jcbbID" : @"",
                    @"ztzt":self.myTitleTextField.text,
                    @"wtfwbnr" : array[0],
                    @"wtwz": array[1],
                    @"wttpList":array[2],
                    @"sfnm":httpNiMing,
                    @"xsz" : @"",
                    @"userID":teacher.teacherID,
                    @"yhlx":teacher.userType};
        
    }else if ([my_wtlx isEqualToString:@"3"]){
        //其他问题
        httpDic = @{@"wtlx":my_wtlx,
                    @"kcID":@"",
                    @"kmID":@"",
                    @"njID":@"",
                    @"cb"  : @"",
                    @"bbmc": @"",
                    @"jcID": @"",
                    @"jcbbID" : @"",
                    @"ztzt":@"",
                    @"wtfwbnr" : array[0],
                    @"wtwz": array[1],
                    @"wttpList":array[2],
                    @"sfnm":httpNiMing,
                    @"xsz" : @"",
                    @"userID":teacher.teacherID,
                    @"yhlx":teacher.userType};
    }
    WEAKSELF(self);
    self.isSubmit = true;
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!xjwt.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            //成功
            //发送通知让上一个界面的列表刷新
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"The question is successful", nil)];
            [weakSelf performSelector:@selector(disMissViewController) withObject:weakSelf afterDelay:2];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Failed to submit the question", nil)];
        }
    }];
}

- (void)disMissViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"questionOk" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 700;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CGRect frame = self.myContentView.frame;
    frame.size.width = SCREEN_WIDTH;
    self.myContentView.frame = frame;
    [cell.contentView addSubview:self.myContentView];
    
    return cell;
}

#pragma mark - seleedViewDelegate
- (void)selectedWithDic:(NSDictionary*)selectedDic andType:(int)type {
    
    selectedClassDic = selectedDic;
    self.classLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[selectedDic objectForKey:@"km"],[selectedDic objectForKey:@"nj"],[selectedDic objectForKey:@"cb"],[selectedDic objectForKey:@"jcbbmc"]];
    CGRect frame = self.classTopView.frame;
    frame.size.height = 129;
    self.classTopView.frame = frame;
    self.myTableView.tableHeaderView = self.classTopView;
    self.courseHeight.constant = 61;
    self.classLabelHeight.constant = 45;
}

@end
