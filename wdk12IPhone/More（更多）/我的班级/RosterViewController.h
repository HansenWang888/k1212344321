//
//  RosterViewController.h
//  wdk12IPhone
//
//  Created by cindy on 15/10/19.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassModel;

@interface RosterViewController : UIViewController

@property (nonatomic, strong) ClassModel *classModel;

///  退出班级成功方法
@property (nonatomic, copy) void(^exitSucceed)(ClassModel *classModel);

@end
