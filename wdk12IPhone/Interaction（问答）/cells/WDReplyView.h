//
//  WDReplyView.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  问题详情页面  回复框
 */

@class WDAnswerDetailModel;
@interface WDReplyView : UIView

@property (nonatomic, copy) void (^closeBlock)();
@property (nonatomic, copy) void (^confirmBlock)(NSString *text);
@property (nonatomic, strong) WDAnswerDetailModel *model;

- (void)reset;
- (void)becomeFirstResponder;
@end
