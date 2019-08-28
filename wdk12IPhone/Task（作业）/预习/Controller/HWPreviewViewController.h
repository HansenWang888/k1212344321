//
//  HWPreviewViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  预习作业控制器
@interface HWPreviewViewController : UIViewController

///  是否提交
@property (nonatomic, assign) BOOL isSubmit;
///  作业id
@property (nonatomic, copy) NSString *taskId;

@property (nonatomic, copy) NSString *studentId;

@end
