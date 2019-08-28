//
//  HWOnlineTaskModel.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/2.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ViewModelClass.h"

@class HWQuestionPaper;

///  在线作业模型
@interface HWOnlineTaskModel : ViewModelClass


///  作业内容类型（试题试卷）
@property (nonatomic, copy) NSString *zynrlx;
///  试题列表
@property (nonatomic, strong) NSArray *stList;
///  试卷列表
@property (nonatomic, strong) NSMutableArray<HWQuestionPaper *> *sjList;

@end
