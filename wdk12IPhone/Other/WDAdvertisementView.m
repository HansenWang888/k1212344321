//
//  WDBackActiveView.m
//  wdk12IPhone
//
//  Created by 老船长 on 2016/12/6.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAdvertisementView.h"
#import <WebKit/WebKit.h>

@interface WDAdvertisementView ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;


@end
@implementation WDAdvertisementView


- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.offset(0);
            make.top.offset(20);
        }];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.activity];
        [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    return self;
}
- (void)btnClick:(UIButton *)sender {
    self.hidden = YES;
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
    [self.activity stopAnimating];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    self.hidden = YES;
    [self removeFromSuperview];
}
#pragma mark - delegate
//监听地址
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
        self.hidden = YES;
        [self removeFromSuperview];
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
@end
