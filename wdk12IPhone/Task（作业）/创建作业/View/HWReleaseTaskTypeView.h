//
//  HWReleaseTaskTypeView.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

///  发布作业类型view
@interface HWReleaseTaskTypeView : UIView

///  选中
@property (nonatomic, copy) void(^didSel)(NSInteger status);
///  选中或取消
@property (nonatomic, copy) void(^selAndCancel)();

///  切换显示发布作业类型View
///
///  @param type true 显示 false 隐藏
- (void)showChangeReleaseTypeWith:(BOOL)type;

@end
