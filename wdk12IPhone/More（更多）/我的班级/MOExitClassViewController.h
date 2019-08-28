//
//  MOExitClassViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSubject;

///  更多模块退出班级控制器
@interface MOExitClassViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<HWSubject *> *data;
///  班级id
@property (nonatomic, strong) NSString *bjId;

@property (nonatomic, copy) void(^exitSucceed)(NSMutableArray<HWSubject *> *data);

@end
