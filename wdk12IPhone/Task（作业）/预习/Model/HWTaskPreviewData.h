//
//  HWTaskPreviewData.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/3.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

///  预习作业资料列表
@interface HWTaskPreviewData : NSObject

///  资料ID
@property (nonatomic, copy) NSString *zlID;
///  资料父ID（用于评价和赞）
@property (nonatomic, copy) NSString *fywID;
///  文件格式
@property (nonatomic, copy) NSString *wjgs;
///  资料名称
@property (nonatomic, copy) NSString *zlmc;
///  资料地扯
@property (nonatomic, copy) NSString *zldz;
///  资料新地扯
@property (nonatomic, copy) NSString *zldznew;
///  评价条数
@property (nonatomic, copy) NSString *pjts;
///  赞条数
@property (nonatomic, copy) NSString *zts;

@end
