//
//  RCTextCtrl.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/12/6.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "RCTxtCtrl.h"

@interface RCTxtCtrl ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation RCTxtCtrl{
    NSURLSessionDownloadTask* _task;
}

-(void)start{
    [self.vc createProgressView];
    self.textView = [UITextView new];
    [self.vc.view addSubview:self.textView];
    [self.textView zk_Fill:self.vc.view insets:UIEdgeInsetsMake(64, 0, 0, 0)];
    WEAKSELF(self);
    _task =  [[NSURLSession sharedSession]downloadTaskWithURL:[NSURL URLWithString:self.path] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error && error.code != NSURLErrorCancelled){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"下载失败", nil)];
            weakSelf.vc.progressView.trackTintColor = [UIColor redColor];
            [weakSelf.vc.progressView setProgress:0];
            return ;
        }
        
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
            
            [weakSelf.vc.progressView setProgress:0.9 animated:YES];
            NSURL *url = [NSURL fileURLWithPath:newpath];
            
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
            weakSelf.textView.text = [NSString stringWithContentsOfURL:url encoding:enc error:nil];
            self.textView.editable = false;
        });
    }];
    [_task resume];
}


@end
