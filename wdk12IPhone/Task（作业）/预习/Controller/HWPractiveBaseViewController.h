//
//  HWPractiveBaseViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 预习作业控制器
@interface HWPractiveBaseViewController : UIViewController

///  是否提交
@property (nonatomic, assign) BOOL isSubmit;
///  试题id
@property (nonatomic, copy) NSString *testId;
///  学生id
@property (nonatomic, copy) NSString *studentId;

@end
