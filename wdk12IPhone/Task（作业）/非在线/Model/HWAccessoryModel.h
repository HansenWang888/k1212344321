//
//  HWAccessoryModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

///  附件模型
@interface HWAccessoryModel : NSObject

///  附件转码地扯
@property (nonatomic, copy) NSString *fjzmdz;
///  附件地扯
@property (nonatomic, copy) NSString *fjdz;
///  附件大小
@property (nonatomic, copy) NSString *fjdx;
///  附件名称
@property (nonatomic, copy) NSString *fjmc;
///  附件格式
@property (nonatomic, copy) NSString *fjgs;
///  附件地扯，不带baseURL
@property (nonatomic, copy) NSString *fjdzNotBaseUrl;

@end
