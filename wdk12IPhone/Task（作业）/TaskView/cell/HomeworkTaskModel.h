//
//  HomeworkTaskModel.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeworkTaskModel : NSObject

///  是否是预习作业
@property (nonatomic, assign) BOOL isPreviewTask;
@property (nonatomic, assign) BOOL isSubmit;

@property (nonatomic, copy) NSString *pxbh;//排序标号
@property (nonatomic, copy) NSString *fz;
@property (nonatomic, copy) NSString *sttg;
@property (nonatomic, copy) NSString *stID;
@property (nonatomic, copy) NSString *stlx;
@property (nonatomic, copy) NSString *tmlx;
@property (nonatomic, copy) NSString *hdda;
@property (nonatomic, copy) NSString *sjID;
//试题解析
@property (nonatomic, copy) NSString *zkg;//主客观题
@property (nonatomic, copy) NSString *stjx;
@property (nonatomic, copy) NSString *stda;
@property (nonatomic, copy) NSString *zsdmc;//知识点
//试题选项
@property (nonatomic, copy) NSArray *stxux;// {"xxnr":"6","xxxh":"C"}
//小题
@property (nonatomic, copy) NSArray<HomeworkTaskModel *> *stxtList;

//学生相关
@property (nonatomic, copy) NSString *mystda;
@property (nonatomic, copy) NSString *mydasfzq;//答案是否正确
@property (nonatomic, copy) NSString *mystdf;//试题得分

+ (instancetype)taskModelWithDict:(NSDictionary *)dict;
+ (instancetype)task06ModelWithDict:(NSDictionary *)dict;
/// 预习作业创建方式
+ (instancetype)practiceTaskModelWithDict:(NSDictionary *)dict;
@end
