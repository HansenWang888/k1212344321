//
//  OnlineTaskOtherSubjectView.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/14.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWQuestionPaper;

@interface OnlineTaskOtherSubjectView : UIView

@property (nonatomic, copy) NSArray<HWQuestionPaper *> *dataSource;

///  选中cell方法
@property (nonatomic, copy) void (^didSelectCellBlock)(HWQuestionPaper *data);

@end
