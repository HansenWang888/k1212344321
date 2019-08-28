//
//  WDMB.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/2/26.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDMB : NSObject
//@property (nonatomic, copy) NSDictionary *subjectMB;//科目码表
+ (NSDictionary *)MBToSubject;//科目码表
+ (NSDictionary *)MBToAdjunctImage;//附件图片

@end
