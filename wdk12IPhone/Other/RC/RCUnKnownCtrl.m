//
//  RCUnKnownCtrl.m
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "RCUnKnownCtrl.h"


@interface RCUnKnownCtrl ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UILabel *erroLabel;

@end
@implementation RCUnKnownCtrl
{
    NSURLSessionDownloadTask* _task;
    UIDocumentInteractionController* _docCtrl;
}
-(void)start{
    [self.vc createProgressView];
//    self.path = [self.path stringByReplacingOccurrencesOfString:@"http" withString:@"attp"];
    _task =  [[NSURLSession sharedSession]downloadTaskWithURL:[NSURL URLWithString:self.path] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.erroLabel.hidden = NO;
            });
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.erroLabel.hidden = YES;
        });
        NSString* localstr = [[location absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
       
        NSString* newpath = [localstr stringByDeletingLastPathComponent];
        
        newpath = [newpath stringByAppendingPathComponent:[self.path lastPathComponent]];
        
        [[NSFileManager defaultManager]removeItemAtPath:newpath error:nil];
        NSError* moveerror = nil;
        
        [[NSFileManager defaultManager]moveItemAtPath:localstr?localstr:@"" toPath:newpath error:&moveerror];
        
        if(moveerror){
            //  [SVProgressHUD showErrorWithStatus:@"文件转移错误"];
            return;
        }
      
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearTask];
            [self.vc.progressView setProgress:0.9 animated:YES];
            NSURL* url = [NSURL fileURLWithPath:newpath];
            UIDocumentInteractionController *documentController =
            
            [UIDocumentInteractionController interactionControllerWithURL:url];
            documentController.delegate = self;
            CGRect rect = CGRectMake(CURRENT_DEVICE_SIZE.width/2.0, 64, 0, 0);
            BOOL isOpen = [documentController presentOpenInMenuFromRect:rect inView:self.vc.view animated:YES];
            if (isOpen == NO) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"不支持该格式文件!", nil)];
            }
            _docCtrl = documentController;
        });
        
        
    }];
    [_task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_task resume];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.vc;
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
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(_task == nil) return;
    if(_task.countOfBytesExpectedToReceive == 0) return;
    
    CGFloat x = (CGFloat)_task.countOfBytesReceived/(CGFloat)_task.countOfBytesExpectedToReceive *0.9;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.vc.progressView setProgress:x animated:YES];
    });
    
}

@end
