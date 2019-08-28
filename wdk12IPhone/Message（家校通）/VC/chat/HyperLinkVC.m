//
//  HyperLinkVC.m
//  wdk12pad
//
//  Created by macapp on 16/2/22.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "HyperLinkVC.h"

@interface HyperLinkVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation HyperLinkVC
{
    NSString* _href;
    NSString* _htmlStr;
}
-(id)initWithHyperLink:(NSString*)href AndTitle:(NSString*)title{
    self = [super init];
    self.title = title;
        _href = href;


    return self;
}
-(id)initWithHtmlStr:(NSString *)htmlstr{
    self = [super init];
    self.title = IMLocalizedString(@"富文本", nil);
    _href = IMLocalizedString(@"伟东云教育", nil);
    NSString* fullhttml = [NSString stringWithFormat:@" <html> <head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no\"> </head> <body> %@</body></html>",htmlstr];
    _htmlStr = fullhttml;

    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* describe = [[UILabel alloc]init];
    describe.text = [NSString stringWithFormat:IMLocalizedString(@"本页面由 %@ 提供", nil),_href] ;
    describe.font = [UIFont systemFontOfSize:13];
    describe.textColor = [UIColor grayColor];
    [describe sizeToFit];
    [_webView addSubview:describe];
    [describe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_webView.mas_centerX);
        make.top.offset(4);
    }];
    [_webView bringSubviewToFront:_webView.scrollView];

//    _webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    if(_htmlStr == nil){
        NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:_href]];
        [_webView loadRequest:req];
    }
    else{
        [_webView loadHTMLString:_htmlStr baseURL:nil];
        NSLog(@"%@",_htmlStr);
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"网页消息");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
