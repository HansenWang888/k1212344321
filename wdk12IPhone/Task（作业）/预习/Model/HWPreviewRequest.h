//
//  HWPreviewRequest.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWTaskPreviewModel;

@interface HWPreviewRequest : NSObject

///  获取预习作业数据
+ (void)fetchPublicPreviewTaskDataWith:(NSString *)taskID handler:(void(^)(HWTaskPreviewModel *data))handler;

@end
