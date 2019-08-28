//
//  HWAddClassViewController.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSubject;

///  添加班级控制器
@interface HWAddClassViewController : UIViewController

///  添加类型 1班级 2小组 3个人
@property (nonatomic, assign) NSInteger addType;
///  科目
@property (nonatomic, strong) HWSubject *subject;

///  选择结果
@property (nonatomic, copy) void(^didResult)(NSArray *data);

@end
