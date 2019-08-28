//
//  WDAnswerByMeViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAnswerByMeViewController.h"
#import "WDQuestionModel.h"
#import "UIImageView+WebCache.h"
#import "WDAttachmentAlertView.h"
#import "MediaOBJ.h"
#import "WDHTTPManager.h"

@interface WDAnswerByMeViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIWebViewDelegate,WDAttachmentAlertDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseTypeLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) WDAttachmentAlertView *alertView;

@property (nonatomic,assign) BOOL isHTTPing;

@end

@implementation WDAnswerByMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
    
}
- (IBAction)confirmClicked:(id)sender {
    if (self.isHTTPing) return;
    NSString *taskContent = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
    NSString *str = [taskContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [str componentsSeparatedByString:@"_wd_"];
    
    if (![array[1] length] && ![array[2] length]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"您还未输入文字,请输入后重新提交", nil)];
        return;
    }
    
    WDTeacher * teacher = [WDTeacher sharedUser];
    NSDictionary * httpDic = @{
                               @"wtID":self.model.questionId,
                               @"wthjID":self.model.hjID,
                               @"wtlx":self.questionYM,
                               @"twrID":self.model.twrID,
                               @"userID":teacher.teacherID,
                               @"hdwz":array[1],
                               @"hdfwbnr" : array[0],
                               @"hdtpList":array[2],
                               @"yhlx":teacher.userType
                               };
    self.isHTTPing = YES;
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!tjwthd.action",EDU_BASE_URL] finished:^(NSDictionary *dic) {
        self.isHTTPing = NO;
        [SVProgressHUD dismiss];
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            if (self.successBlock) {
                self.successBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"回答失败", nil)];
        }
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.1];
    }
    return true;
}

#pragma mark WDAttachmentAlertDelegate
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

    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"上传附件", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"拍照", nil),NSLocalizedString(@"相册", nil),NSLocalizedString(@"手写", nil), nil, nil];
    self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self aler:alert];
    self.alertView.attachmentDelegate = self;
    self.alertView.isWrite = YES;
    [self.alertView show];
}

- (void)initSubViews {
    self.title = NSLocalizedString(@"我来回答", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!self.model) return;
    
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
    
    NSString *titStr = self.model.wtwz;
    if (!titStr.length || !titStr) {
        titStr = NSLocalizedString(@"图片问题", nil);
    }
    self.titleLabel.text = titStr;
    self.titleLabel.font = [UIFont systemFontOfSize:13.0];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.dateLabel.text = self.model.twrq;
    
    self.courseLabel.text = [NSString stringWithFormat:@"%@%@%@%@", self.model.km,self.model.nj,self.model.cb,self.model.jcbbmc];
    self.courseLabel.preferredMaxLayoutWidth = 150;
    
    if ([self.model.sfnm isEqualToString:@"false"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.model.icon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        self.nameLabel.text = self.model.twr;
    }else {
        self.iconImageView.image = [UIImage imageNamed:@"default_touxiang"];
        self.nameLabel.text = NSLocalizedString(@"***", nil);
    }
    
    
    //问题类型
    NSString * wtlx;
    if ([self.model.wtlx isEqualToString:@"1"]) {
        wtlx = NSLocalizedString(@"课程疑问", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0xF7B964 alpha:1];
    }else if ([self.model.wtlx isEqualToString:@"2"]){
        wtlx = NSLocalizedString(@"专题讨论", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0x61B961 alpha:1];
    }else if ([self.model.wtlx isEqualToString:@"3"]){
        wtlx = NSLocalizedString(@"其他问题", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0xA453CE alpha:1];
    }
    self.courseTypeLabel.text = wtlx;
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    
}

@end
