//
//  HWSubject.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWSubject : NSObject

@property (nonatomic, copy) NSString *subjectID;
@property (nonatomic, copy) NSString *subjectCH;
///  自身所在的索引
@property (nonatomic, strong) NSIndexPath *index;

///  是否选中
@property (nonatomic, assign) BOOL isSel;
///  是否选中
@property(nonatomic,getter=isOn) BOOL on;

+ (instancetype)subjectWithDict:(NSDictionary *)dict;

///  类方法赋值
///
///  @param dict 数据源
///
///  @return 科目对象
+ (instancetype)subjectWithDictIDAndMC:(NSDictionary *)dict;

@end
