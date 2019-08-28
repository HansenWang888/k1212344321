//
//  MOAddClassViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassModel;

///  更多模块添加班级控制器
@interface MOAddClassViewController : UIViewController

///  我的班级数据
@property (nonatomic, copy) NSArray<ClassModel *> *myClassData;

@end
