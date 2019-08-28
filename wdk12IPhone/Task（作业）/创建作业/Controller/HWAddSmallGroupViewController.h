//
//  HWAddSmallGroupViewController.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ViewModelClass.h"

///  添加小组控制器
@interface HWAddSmallGroupViewController : UIViewController

///  添加类型 true 小组 false 个人
@property (nonatomic, assign) BOOL addType;
///  班级id
@property (nonatomic, copy) NSString *classId;

///  选择结果
@property (nonatomic, copy) void(^didSelResult)(NSArray *data);

@end
