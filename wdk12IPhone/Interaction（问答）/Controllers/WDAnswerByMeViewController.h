//
//  WDAnswerByMeViewController.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  我来回答页面
 */
@class WDQuestionModel;
@interface WDAnswerByMeViewController : UIViewController

@property (nonatomic, copy) void (^successBlock)();
@property (nonatomic, strong) WDQuestionModel *model;

@property (nonatomic, strong) NSString *questionYM; //(全部 qb 我的 wd)

@end
