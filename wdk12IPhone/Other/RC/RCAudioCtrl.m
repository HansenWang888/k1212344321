//
//  RCAudio.m
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "RCAudioCtrl.h"

@interface RCAudioCtrl() <UIWebViewDelegate>

@end

@implementation RCAudioCtrl


-(void)start{
    [self.vc createProgressView];
    [self.vc createWebView];
    self.vc.webview.delegate = self;
    
    [self.vc.webview loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"audio.html" withExtension:nil]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.vc.progressView setProgress:1 animated:YES];
    self.vc.progressView.hidden = YES;
    
    NSString* js = [NSString stringWithFormat:@"setAudio('%@')",self.path];
    [webView stringByEvaluatingJavaScriptFromString:js];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.vc.progressView.trackTintColor = [UIColor redColor];
    [self.vc.progressView setProgress:0];
}


@end
