//
//  TaskPreviewModel.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/3.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWTaskPreviewPractice;
@class HWTaskPreviewData;

///  预习作业模型
@interface HWTaskPreviewModel : NSObject

///  预习资料列表
@property (nonatomic, strong) NSMutableArray<HWTaskPreviewData *> *zlList;
///  预习练习列表
@property (nonatomic, strong) NSMutableArray<HWTaskPreviewPractice *> *lxList;

@end
