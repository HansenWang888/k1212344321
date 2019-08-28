//
//  WDPromptView.h
//  wdk12studyHD-T
//
//  Created by 老船长 on 16/1/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDPromptView : UIView
@property (nonatomic, copy) NSString *promptMessage;//提示语..
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (void)setPromtVWithHidden:(BOOL)isHidden isAnimation:(BOOL)isAnimation activityHidden:(BOOL)activityIsH promtStr:(NSString *)promtStr;
+ (instancetype)promptView;
@end
