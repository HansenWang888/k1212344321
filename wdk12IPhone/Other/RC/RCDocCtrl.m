//
//  RCDocCtrl.m
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "RCDocCtrl.h"

@interface RCDocCtrl() <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *docCtrl;
@property (nonatomic, strong) UILabel *erroLabel;

@end
@implementation RCDocCtrl{
    NSURLSessionDownloadTask* _task;
}
-(void)start{
    [self.vc createProgressView];
    
    _task =  [[NSURLSession sharedSession]downloadTaskWithURL:[NSURL URLWithString:self.path] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error && error.code != NSURLErrorCancelled){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"下载失败", nil)];
            self.vc.progressView.trackTintColor = [UIColor redColor];
            [self.vc.progressView setProgress:0];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.erroLabel.hidden = YES;
        });
        NSString* localstr = [[location absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSString* newpath = [localstr stringByDeletingLastPathComponent];
        
        newpath = [newpath stringByAppendingPathComponent:self.path.lastPathComponent];
        
        [[NSFileManager defaultManager]removeItemAtPath:newpath error:nil];
        NSError* moveerror = nil;
        
        [[NSFileManager defaultManager]moveItemAtPath:localstr?localstr:@"" toPath:newpath error:&moveerror];
        if(moveerror){
              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"文件转移错误", nil)];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearTask];
            [self.vc.progressView setProgress:0.9 animated:YES];
            NSURL* url = [NSURL fileURLWithPath:newpath];
            UIDocumentInteractionController *documentController =
            [UIDocumentInteractionController interactionControllerWithURL:url];
            documentController.delegate = self;
            _docCtrl = documentController;
            _docCtrl.name = self.name;
            BOOL isOpen = [documentController presentPreviewAnimated:NO];
            if (isOpen == NO) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"打开失败", nil)];
            }
        });
    }];
    [_task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_task resume];
}
/*-(void)start{
    [self.vc createProgressView];
    
    _task =  [[NSURLSession sharedSession]downloadTaskWithURL:[NSURL URLWithString:self.path] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error && error.code != NSURLErrorCancelled){
            [SVProgressHUD showErrorWithStatus:@"下载失败"];
            self.vc.progressView.trackTintColor = [UIColor redColor];
            [self.vc.progressView setProgress:0];
            return ;
        }
        
        NSString* filestr = [location absoluteString];
        filestr = [filestr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSData* data = [[NSFileManager defaultManager]contentsAtPath:filestr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearTask];
            [self.vc.progressView setProgress:0.9 animated:YES];
            
            [self.vc createWebView];
            
            self.vc.webview.delegate = self;
            [self.vc.webview loadData:data MIMEType:response.MIMEType textEncodingName:response.textEncodingName baseURL:nil];
        });
    }];
    [_task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_task resume];
}*/

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return self.vc;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    if (self.vc.navigationController.viewControllers.count > 1) {
        [self.vc.navigationController popViewControllerAnimated:NO];
        return;
    }
    [self.vc dismissViewControllerAnimated:NO completion:nil];
}
-(void)end{
    [self clearTask];
}

-(void)clearTask{
    if(_task){
        [_task removeObserver:self forKeyPath:@"countOfBytesReceived"];
        if(_task.state == NSURLSessionTaskStateSuspended||
           _task.state == NSURLSessionTaskStateRunning){
            [_task cancel];
        }
        _task = nil;
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(_task == nil) return;
    if(_task.countOfBytesExpectedToReceive == 0) return;
    
    CGFloat x = (CGFloat)_task.countOfBytesReceived/(CGFloat)_task.countOfBytesExpectedToReceive *0.9;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.vc.progressView setProgress:x animated:YES];
    });
 
}
- (UILabel *)erroLabel {
    if (!_erroLabel) {
        _erroLabel = [[UILabel alloc] init];
        _erroLabel.font = [UIFont fontWithName:@"iconfont" size:80];
        _erroLabel.text = @"\U0000e60d";
        [_erroLabel sizeToFit];
        _erroLabel.textColor = [UIColor grayColor];
        _erroLabel.center = CGPointMake(CURRENT_DEVICE_SIZE.width * 0.5, CURRENT_DEVICE_SIZE.height * 0.5);
        
        [self.vc.view addSubview:_erroLabel];
    }
    return _erroLabel;
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.vc.progressView setProgress:1 animated:YES];
    self.vc.progressView.hidden = YES;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    self.vc.progressView.trackTintColor = [UIColor redColor];
    [self.vc.progressView setProgress:0];
}

@end
