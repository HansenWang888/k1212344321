//
//  WDOpenFileOBJ.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/1/14.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "WDOpenFileOBJ.h"

#import "MoviePlayerController.h"
#import "CheckPictureController.h"
#import <AFNetworking.h>
#import "WDProgressView.h"

@interface WDOpenFileOBJ ()<UIDocumentInteractionControllerDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) NSCache *downloadCache;//用作下载缓存
@property (nonatomic, strong) UIDocumentInteractionController *documentController;//打开第三方应用
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) WDProgressView *progressV;

@end

@implementation WDOpenFileOBJ

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canleDownload) name:@"CANCLE_DOWNLOAD" object:nil];
    }
    return self;
}
- (void)canleDownload {
    
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"是否取消下载", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"否", nil) otherButtonTitles:NSLocalizedString(@"是", nil), nil];
    [alertV show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        //停止当前所有下载操作
        _progressV.alpha = 0.0;
        _progressV.value = 0.0;
        for (NSURLSessionDownloadTask *down in self.sessionManager.downloadTasks) {
            [down cancel];
        }
    }
}

- (void)openFileWithFileFormatter:(NSString *)formatter fileName:(NSString *)fileName fileUrl:(NSString *)fileUrl controller:(UIViewController *)VC {
    
    if ([formatter isEqualToString:@"MP4"] || [formatter isEqualToString:@"AVI"] || [formatter isEqualToString:@"WAV"] || [formatter isEqualToString:@"WMA"] || [formatter isEqualToString:@"RMVB"] || [formatter isEqualToString:@"MP3"]) {
        
        NSString *urlStr = fileUrl;
        if (![fileUrl containsString:@"http"]) {
            urlStr = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL,fileUrl];
        }
        
        
        NSURL *url = [NSURL URLWithString:urlStr];
        [VC setHidesBottomBarWhenPushed:YES];
        MoviePlayerController *movieController = [[MoviePlayerController alloc] init];
        [movieController stepUIAndURL:url];
        movieController.titleAsset = fileName;
        [VC presentViewController:movieController animated:YES completion:nil];
        
    } else if ([formatter isEqualToString:@"JPG"] || [formatter isEqualToString:@"GIF"] || [formatter isEqualToString:@"PNG"]) {
        CheckPictureController *photo = [[CheckPictureController alloc] init];
        ;
        

        photo.picUrl = fileUrl;//[NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL, fileUrl];
        if (![photo.picUrl containsString:@"http"]) {
            photo.picUrl = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL, fileUrl];
        }
        
        //图片
        [VC presentViewController:photo animated:YES completion:nil];
    } else {
        
//        NSString *urlString = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL,fileUrl];
        NSString *urlString = fileUrl;
        if (![fileUrl containsString:@"http"]) {
            urlString = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL,fileUrl];
        }
        
        //先从缓存取
        if ([self.downloadCache objectForKey:urlString] != nil) {
            self.documentController.URL = [self.downloadCache objectForKey:urlString];
            BOOL isOpen = [self.documentController presentOpenInMenuFromRect:VC.view.bounds inView:VC.view animated:YES];
            if (isOpen == NO) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"打开失败", nil)];
            }
            return;
        }
        //先下载
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
        self.sessionManager = manager;
        self.progressV.alpha = 1.0;
        [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressV.value = downloadProgress.fractionCompleted;
                if (downloadProgress.fractionCompleted >= 1) {
                    _progressV.alpha = 0;
                    _progressV.value = 0;
                }
            });
        } destination: ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSString *cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileUrl]];
            NSURL *url = [NSURL fileURLWithPath:cacheDir];
            return url;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSLog(@"filePath == %@",filePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil && filePath) {
                    [self.downloadCache setObject:filePath forKey:urlString];
                    self.documentController.URL = filePath;
                    BOOL isOpen = [self.documentController presentOpenInMenuFromRect:VC.view.bounds inView:VC.view animated:YES];
                    
                    if (isOpen == NO) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"打开失败", nil)];
                    }
                } else if (error) {
                    WDULog(@"下载文件%@",error);
                    self.progressV.hidden = YES;
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"下载失败", nil)];
                }
            });
        }] resume];
    }
}
- (NSCache *)downloadCache {
    if (!_downloadCache) {
        _downloadCache = [[NSCache alloc] init];
    }
    return _downloadCache;
}
- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        _documentController = [[UIDocumentInteractionController alloc] init];
        _documentController.delegate = self;
    }
    return _documentController;
}
- (WDProgressView *)progressV {
    if (!_progressV) {
        _progressV = [[WDProgressView alloc] init];
        _progressV.frame = CURRENT_WINDOW.bounds;
        [CURRENT_WINDOW addSubview:_progressV];
    }
    return _progressV;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCLE_DOWNLOAD" object:nil];
    [_progressV removeFromSuperview];
}
@end
