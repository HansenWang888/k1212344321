//
//  HWPracticeViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  预习练习控制器
@interface HWPracticeViewController : UIViewController

///  是否提交
@property (nonatomic, assign) BOOL isSubmit;
///  试题id
@property (nonatomic, copy) NSString *testId;
///  学生id
@property (nonatomic, copy) NSString *studentId;

@end
