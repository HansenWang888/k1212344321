//
//  WDBackActiveView.m
//  wdk12IPhone
//
//  Created by 老船长 on 2016/12/6.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDBackActiveView.h"
#import <WebKit/WebKit.h>

@interface WDBackActiveView ()<WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *closeBtn;

@end
@implementation WDBackActiveView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.webView];
        [self addSubview:self.closeBtn];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.right.offset(-20);
            make.width.offset(60);
            make.height.offset(21);
        }];
    }
    return self;
}
- (void)btnClick:(UIButton *)sender {
    self.hidden = YES;
}
- (void)loadWebViewWithURL:(NSString *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark - delegate

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [WKWebView new];
        _webView.UIDelegate = self;
    }
    return _webView;
}
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_closeBtn setTitle:NSLocalizedString(@"关闭", nil) forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.closeBtn.backgroundColor = [UIColor grayColor];
        [_closeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
@end
