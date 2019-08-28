//
//  HMClassesList.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWClassesList : NSObject
@property (nonatomic, copy) NSString *bjID;
@property (nonatomic, copy) NSString *bjmc;
@property (nonatomic, copy) NSString *bjtp;
@property (nonatomic, copy) NSString *xsrs;

+ (instancetype)classesListWithDict:(NSDictionary *)dict;
@end
