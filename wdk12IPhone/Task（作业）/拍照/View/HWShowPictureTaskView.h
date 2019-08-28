//
//  HWShowPictureTaskView.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPhotographModel;

///  显示照片作业view
@interface HWShowPictureTaskView : UIView

@property (nonatomic, copy) void(^currentPage)(NSInteger);

@property (nonatomic, weak) UIViewController *superViewController;

- (void)setValueForDataSource:(HWPhotographModel *)data;

@end
