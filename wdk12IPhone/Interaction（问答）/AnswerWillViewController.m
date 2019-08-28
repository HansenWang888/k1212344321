//
//  AnswerWillViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/12/2.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "AnswerWillViewController.h"
#import "UIImageView+WebCache.h"
#import "WDAttachmentAlertView.h"
#import "WDHTTPManager.h"
#import "MediaOBJ.h"

@interface AnswerWillViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, WDAttachmentAlertDelegate>

@property (strong, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *footView;

@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@property (weak, nonatomic) IBOutlet UILabel *shijian;
@property (weak, nonatomic) IBOutlet UILabel *kecheng;
@property (weak, nonatomic) IBOutlet UILabel *kechengType;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *userhard;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (nonatomic, strong) WDAttachmentAlertView *alertView;

@end

@implementation AnswerWillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    self.title = NSLocalizedString(@"I'll answer", nil);
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.webView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.webView.layer.borderWidth = 1.0;
    self.webView.layer.cornerRadius = 2.0f;
    self.webView.delegate = self;
    self.webView.delegate = self;
    NSString *path = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/webapp/app/jsp/index.html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    
    NSString *titStr = self.info[@"wtwz"];
    if (!titStr.length || !titStr) {
        titStr = @"图片问题";
    }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[titStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.myTitle.attributedText = attr;
    self.myTitle.numberOfLines = 0;
    self.myTitle.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 100;
    
    self.shijian.text = [self.info objectForKey:@"twrq"];
    self.kecheng.text = [NSString stringWithFormat:@"%@%@%@", [self.info objectForKey:@"km"],[self.info objectForKey:@"nj"],[self.info objectForKey:@"cb"]];
    self.kecheng.preferredMaxLayoutWidth = 150;//[UIScreen wd_screenWidth] - 160;
    self.kecheng.numberOfLines = 0;
    
    [self.userhard sd_setImageWithURL:[NSURL URLWithString:[self.info objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
    self.userName.text = [self.info objectForKey:@"twr"];
    //问题类型
    NSString * wtlx;
    if ([[self.info objectForKey:@"wtlx"] isEqualToString:@"1"]) {
        wtlx = NSLocalizedString(@"Course Questions", nil);
    }else if ([[self.info objectForKey:@"wtlx"] isEqualToString:@"2"]){
        wtlx = NSLocalizedString(@"Seminar", nil);
    }else if ([[self.info objectForKey:@"wtlx"] isEqualToString:@"3"]){
        wtlx = NSLocalizedString(@"Other problems", nil);
    }
    self.kechengType.text = wtlx;
    
    self.myTableView.tableHeaderView = self.headView;
    self.myTableView.tableFooterView = self.footView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.1];
    }
    return true;
}

///  选择照片来源
- (void)selectPhotoFrom {
    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Attachment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"Take pictures", nil),NSLocalizedString(@"Album", nil), nil];
    self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self aler:alert];
    self.alertView.attachmentDelegate = self;
    [self.alertView show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"init()"];
    [webView stringByEvaluatingJavaScriptFromString:@"setCurrentType('2')"];
}

//MARK:WDAttachmentAlertDelegate
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"uploading", nil)];
    
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

///  提交答案方法
- (IBAction)submitAnswerAction {
    NSString *taskContent = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
    NSString *str = [taskContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [str componentsSeparatedByString:@"_wd_"];
    
    
    if ([array[1] length] == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"You have not entered text yet. Please enter it and resubmit", nil)];
        return;
    }

    WDTeacher * teacher = [WDTeacher sharedUser];
    NSDictionary * httpDic = @{@"wtID":self.info[@"id"],
                               @"wthjID":self.info[@"hjID"],
                               @"wtlx":@"qd",
                               @"twrID":self.info[@"twrID"],
                               @"userID":teacher.teacherID,
                               @"hdwz":array[1],
                               @"hdfwbnr" : array[0],
                               @"hdtpList":array[2],
                               @"yhlx":teacher.userType};
    
    
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!tjwthd.action",EDU_BASE_URL] finished:^(NSDictionary *dic) {
        
        //        NSLog(@"%@",dic);
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            
            //发送成功消息 让详情界面刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"replyOk" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Answer failed", nil)];
        }
    }];
}

#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

@end
