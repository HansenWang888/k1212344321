//
//  WDAdvertisementVC.m
//  wdk12IPhone
//
//  Created by 老船长 on 2017/3/23.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "WDAdvertisementVC.h"
#import <WebKit/WebKit.h>
#import "WDHTTPManager.h"
@interface WDAdvertisementVC ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, copy) void(^closeBlock)();
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation WDAdvertisementVC

+ (instancetype)advertisementWithURL:(NSString *)url closeBlock:(void (^)())closeBlock {
    WDAdvertisementVC *vc = [WDAdvertisementVC new];
    [vc getAdvertisementAddressWithURL:url];
    vc.closeBlock = closeBlock;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.offset(20);
    }];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.activity];
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    
    // Do any additional setup after loading the view.
}
- (void)getAdvertisementAddressWithURL:(NSString *)url {
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:nil urlString:url finished:^(NSDictionary *response) {
        if (response) {
            NSString *address = response[@"data"][@"noticeUrl"];
            if (address.length > 0) {
                [self loadWebViewWithURL:address];
            } else {
                self.closeBlock();
            }
        } else {
            self.closeBlock();

        }
    }];
}
- (void)loadWebViewWithURL:(NSString *)url {
    [self.activity startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    //    [self.webView loadHTMLString:@"<html><head><meta charset=\"utf-8\" /><title></title></head><body><input type='button' value=\"关闭页面\" onclick=\"closeWebView()\"></body><script>function closeWebView() {var u = navigator.userAgent;var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1; if(isAndroid){window.webview.close();} else {window.webkit.messageHandlers.closeWebView.postMessage(null); } }</script></html>" baseURL:nil];
}
#pragma mark - navigationdelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.imgView.hidden = YES;
    [self.activity stopAnimating];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    self.closeBlock();
    self.closeBlock = nil;
}
//有跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    UIApplication *app = [UIApplication sharedApplication];
    // 打电话
    if ([scheme isEqualToString:@"tel"]) {
        if ([app canOpenURL:URL]) {
            [app openURL:URL];
            // 一定要加上这句,否则会打开新页面
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 打开appstore
    if ([URL.absoluteString containsString:@"itunes.apple.com"]) {
        if ([app canOpenURL:URL]) {
            [app openURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
}
//有响应
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    //    //获取请求的url路径.
    //    NSString *requestString = navigationResponse.response.URL.absoluteString;
    //    NSLog(@"requestString:%@",requestString);
    //    // 遇到要做出改变的字符串
    //    NSString *head = [requestString componentsSeparatedByString:@"://"][0];
    //    NSString *tail = [requestString componentsSeparatedByString:@"://"][1];
    //    if ([tail isEqualToString:@"closeWebView"]) {
    //        //点击了关闭按钮
    //        self.hidden = YES;
    //        [self removeFromSuperview];
    //    }
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}
//js调用OC
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeWebView"]) {
        self.closeBlock();
        self.closeBlock = nil;
    }
}
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [WKWebView new];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        //注册相关的方法，在js中通过window.webkit.messageHandlers.closeWebView.postMessage(null),没有参数时必须传null,不然js会报错
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"closeWebView"];
        
    }
    return _webView;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [UIActivityIndicatorView new];
        _activity.color = [UIColor blackColor];
    }
    return _activity;
    
}
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.image = [UIImage imageNamed:@"launchImage_ch"];
    }
    return _imgView;
}
- (void)dealloc {
    NSLog(@"advertisementVC - 888");

}
@end
