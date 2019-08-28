//
//  ResourceVCViewController.m
//  wdk12pad
//
//  Created by macapp on 15/12/29.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "ResourceVCViewController.h"
#import "RCCtrl.h"



@interface ResourceVCViewController ()<UIWebViewDelegate>

@end

@implementation ResourceVCViewController{
    RCCtrl* _ctrl;
}
-(id)initWithPath:(NSString*)path ConverPath:(NSString*)converpath Type:(NSString*)type Name:(NSString*)name{
    self = [super init];
    
    self.title = name;
    if (converpath.length == 0) {
        converpath = path;
    }
    if (![path hasPrefix:@"http"] && ![converpath hasPrefix:@"file"]) {
        path = [FILE_SEVER_DOWNLOAD_URL stringByAppendingPathComponent:path];
        converpath = [FILE_SEVER_DOWNLOAD_URL stringByAppendingPathComponent:converpath];
    }
    
    _ctrl = [RCCtrl initWithPath:path ConverPath:converpath Type:type Name:name VC:self];
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [_ctrl start];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setBackItemWithFontName:@"iconfont" title:@"\U0000e613" fontSize:20]];
}
- (UIButton *)setBackItemWithFontName:(NSString *)fontName title:(NSString *)title fontSize:(CGFloat)fontSize {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [btn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    return btn;
}
- (void)backBtnClick {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
    [_ctrl end];
}
-(void)createWebView{
    _webview = [[UIWebView alloc]init];
    //    _webview.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.view addSubview:_webview];
    [_webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    _webview.scalesPageToFit = true;
    [self.view bringSubviewToFront:_progressView];
}
-(void)createProgressView{
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.equalTo(self.view);
        make.top.offset(0);
        make.height.offset(4);
    }];
}

@end
