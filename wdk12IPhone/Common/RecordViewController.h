//
//  ViewController.h
//  录音和播放
//
//  Created by 老船长 on 15/12/28.
//  Copyright © 2015年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordViewVCDelegate <NSObject>

- (void)recordCompeletedWithRecordURL:(NSString *)recordURL recordData:(NSData *)data;

@end

@interface RecordViewController : UIViewController
@property (nonatomic, weak) id<RecordViewVCDelegate> recordDelegate;

@end

