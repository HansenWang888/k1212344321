//
//  WDAttachmentAlertView.h
//  wdk12pad
//
//  Created by 老船长 on 16/7/2.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDAttachmentAlertDelegate <NSObject>
@optional
- (void)attachmentWithPhotos:(NSArray<UIImage *> *)imgs;
- (void)attachmentWithVideoURL:(NSURL *)url;
- (void)attachmentWithRecordURL:(NSURL *)url;
- (void)imageAfterDrawing:(UIImage *)image;
@end

@interface WDAttachmentAlertView : UIAlertView


+ (instancetype)attachmentAlertViewWithVC:(UIViewController *)vc;

+ (instancetype)attachmentAlertViewWithVC:(UIViewController *)vc aler:(WDAttachmentAlertView *)aler;

@property (weak, nonatomic) id<WDAttachmentAlertDelegate> attachmentDelegate;

@property (nonatomic,assign) BOOL isWrite;

@end
