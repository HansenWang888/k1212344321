//
//  WDCourseDetailModel.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCourseDetailModel : NSObject

@property (nonatomic, copy) NSString *cb;
@property (nonatomic, copy) NSString *jcbbmc;
@property (nonatomic, copy) NSString *jcid;
@property (nonatomic, copy) NSString *njID;
@property (nonatomic, copy) NSString *kmID;
@property (nonatomic, copy) NSString *jcbbid;
@property (nonatomic, copy) NSString *nj;
@property (nonatomic, copy) NSString *km;

+ (WDCourseDetailModel *)getCourseModelWith:(NSDictionary *)dict;


@end
