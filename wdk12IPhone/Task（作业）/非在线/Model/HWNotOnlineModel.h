//
//  HWNotOnlineModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWAccessoryModel;

@interface HWNotOnlineModel : NSObject

///  作业内容
@property (nonatomic, copy) NSString *zynr;
///  附件列表
@property (nonatomic, strong) NSMutableArray<HWAccessoryModel *> *fjList;

@end
