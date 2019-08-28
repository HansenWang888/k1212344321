//
//  HWPhotographModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWPhotographModel : NSObject

///  附件ID
@property (nonatomic, copy) NSString *fjID;
///  附件地址
@property (nonatomic, copy) NSString *fjdz;
///  试题列表
@property (nonatomic, strong) NSMutableArray<HWPhotographModel *> *stList;
///  排序编号
@property (nonatomic, copy) NSString *pxbh;
///  试题ID
@property (nonatomic, copy) NSString *stID;
///  题目类型代码
@property (nonatomic, copy) NSString *tmlxdm;
///  选项个数
@property (nonatomic, copy) NSString *xuxgs;


//  学生id
@property (nonatomic, copy) NSString *xsID;
//  学生姓名
@property (nonatomic, copy) NSString *xsxm;
//  反馈列表
@property (nonatomic, strong) NSMutableArray<HWPhotographModel *> *fkList;
//  学生附件ID
@property (nonatomic, copy) NSString *xsfjID;
//  作业附件ID
@property (nonatomic, copy) NSString *zyfjID;
//  学生附件地址
@property (nonatomic, copy) NSString *xsfjdz;
//  得分
@property (nonatomic, copy) NSString *df;
//  得分
@property (nonatomic, copy) NSString *fz;
//  判题结果
@property (nonatomic, copy) NSString *ptjg;
//  学生答案
@property (nonatomic, copy) NSString *xsdaan;
//  正确答案
@property (nonatomic, copy) NSString *zqdaan;

//批改附件
@property (nonatomic, strong) NSMutableArray<HWPhotographModel *> *pgfjList;
//批改附件名称
@property (nonatomic, copy) NSString *fjmc;
//批改附件大小
@property (nonatomic, copy) NSString *fjdx;
//批改附件格式
@property (nonatomic, copy) NSString *fjgs;


+ (void)getPhotoraphTaskDetailWithZYID:(NSString *)zyId handler:(void(^)(NSArray *stData))handler ;

+ (void)getPhotoraphTaskFeedbackWithFbdxId:(NSString *)fbdxId fbdxlx:(NSString *)fbdxlx zyId:(NSString *)zyId handler:(void(^)(NSArray *xsData))handler;

///  拍照作业反馈接口
+ (void)phototgraphTaskFeedbackWithFbdxID:(NSString *)fbdxID jsID:(NSString *)jsID xsID:(NSString *)xsID zyID:(NSString *)zyID fkList:(NSArray *)fkList handler:(void(^)(BOOL))handler;

@end
