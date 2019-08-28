//
//  WDQuestionDetailViewController.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  问题详情页面
 */
@class WDQuestionModel;
@interface WDQuestionDetailViewController : UIViewController

@property (nonatomic, strong) WDQuestionModel *model;
@property (nonatomic, strong) NSString *questionYM; //问题页面 （sywt 全部问题）（wdwt我的问题）

@end
