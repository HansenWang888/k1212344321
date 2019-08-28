//
//  HWTaskPreviewPractice.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/3.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

///  预习作业练习模型
@interface HWTaskPreviewPractice : NSObject

///  练习详情ID
@property (nonatomic, copy) NSString *xqID;
///  类型
@property (nonatomic, copy) NSString *lx;
//（预习基础练习：2， 预习拓展练习：3）
@property (nonatomic, copy) NSString *lxbm;

@end
