//
//  WebViewEditTableViewCell.m
//  wdk12pad
//
//  Created by 王振坤 on 16/7/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "Homework05TextCell.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface Homework05TextCell ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
///  答题内容
@property (nonatomic, strong) NSMutableDictionary *dictM;

@property (nonatomic, copy) void (^submitTask)(NSArray *data);

@end

@implementation Homework05TextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
//    self.webView = [UIWebView new];
//    [self.contentView addSubview:self.webView];
//    self.webView.layer.borderColor = [UIColor grayColor].CGColor;
//    self.webView.layer.borderWidth = 1.0;
//    self.webView.backgroundColor = [UIColor whiteColor];
//    NSString *path = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/webapp/app/jsp/index.html"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    self.webView.delegate = self;
//    [self.webView loadRequest:request];
//    self.dictM = [NSMutableDictionary dictionary];
    
    self.contentLabel = [UILabel new];
    [self.contentView addSubview:self.contentLabel];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
//    [self.contentLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 20, <#CGFloat height#>) offset:CGPointMake(10, 10)];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.top.offset(10);
        make.right.offset(-10);
    }];
    self.contentLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentLabel.layer.borderWidth = 1.0;
}

- (void)initAutoLayout {
//    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.offset(10);
//        make.right.offset(-10);
//        make.top.bottom.equalTo(self.contentView);
//    }];
}

- (void)setAnswer:(NSString *)answer {
    _answer = answer;
    
    NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 14px;width:100%%;color: black;font-weight:bold} img{max-width:%f !important;}</style></html>", answer ? answer : @"", [UIScreen wd_screenWidth] - 20];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    if ([answer isEqualToString:@"."]) {
        self.contentLabel.text = @"\n";
    } else {
        self.contentLabel.attributedText = attr;
    }
    [self.contentView layoutIfNeeded];
}

- (void)setValueForDataSource:(NSString *)data {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

#pragma mark - webView delegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
////    NSLog(@"%@", request.URL.absoluteString);
//    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
//        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.5];
//    } else if ([request.URL.absoluteString containsString:@"wd3:"]) {
//        NSString *str = [request.URL.absoluteString substringWithRange:NSMakeRange(4, request.URL.absoluteString.length - 4)];
//        NSString *str1 = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSArray *array = [str1 componentsSeparatedByString:@"_wd_"];
//        if (self.submitTask) {
//            self.submitTask(array);
//        }
//    }
//    return true;
//}

///  选取图片来源
//- (void)selectPhotoFrom {
//    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择图片来源" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照", @"相册", nil];
//    [alert show];
//}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {// 不支持拍照
////            [SVProgressHUD showErrorWithStatus:@"不支持拍照"];
//            return ;
//        }
//        UIImagePickerController *vc = [UIImagePickerController  new];
//        vc.delegate = self;
//        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self.superViewController presentViewController:vc animated:true completion:nil];
//    } else if (buttonIndex == 2) {
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {// 不支持拍照
////            [SVProgressHUD showErrorWithStatus:@"当前相册不可用"];
//            return ;
//        }
//        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        // 编辑模式
//        imagePicker.allowsEditing = NO;
//        [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
//    }
//}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [webView stringByEvaluatingJavaScriptFromString:@"init()"];
//        [webView stringByEvaluatingJavaScriptFromString:@"setCurrentType('2')"];
//        if (self.answer.length != 0) {
//            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setRichText('%@')",self.answer]];
//        }
//    });
//}
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"didFailLoadWithError %@",error);
//
//}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    if ([self.delegate respondsToSelector:@selector(EditTableViewCellUploadPhotoAttachment:finished:)]) {
//        [self.delegate EditTableViewCellUploadPhotoAttachment:UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.3) finished:^(NSString *imageURL) {
//            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"appendAttachment('%@')", imageURL]];
//        }];
//    }
//    [self.superViewController dismissViewControllerAnimated:true completion:nil];
//}
///  获取提交内容方法
//- (NSString *)getSubmitContentBlock:(void (^)(NSArray *))block {
//    _submitTask = block;
//    NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
//   return content;
//}

@end
