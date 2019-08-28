//
//  WDQuestionModel.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDQuestionModel : NSObject

@property (nonatomic, copy) NSString *hjID;//行键ID
@property (nonatomic, copy) NSString *questionId; //问题ID
@property (nonatomic, copy) NSString *twrID;//提问人ID
@property (nonatomic, copy) NSString *twr;//提问人
@property (nonatomic, copy) NSString *sfnm;//是否匿名
@property (nonatomic, copy) NSString *icon;//提问人头像
@property (nonatomic, copy) NSString *wtwz;//问题文字
@property (nonatomic, strong) NSArray *wttpList;//问题图片列表 [{url=http://xxxx.png}]
//@property (nonatomic, copy) NSString *sffwb;//是否是富文本格式
@property (nonatomic, copy) NSString *wtfwbnr;//问题富文本内容
@property (nonatomic, copy) NSString *twrq;//提问日期
@property (nonatomic, copy) NSString *syxsz;//剩余悬赏值
@property (nonatomic, copy) NSString *km;//科目
@property (nonatomic, copy) NSString *nj;//年级
@property (nonatomic, copy) NSString *cb;//册别
@property (nonatomic, copy) NSString *jcbbmc;//教材版本名称
@property (nonatomic, copy) NSString *ztzt;//专题题目(如果没有就返回””)
@property (nonatomic, copy) NSString *wtlx;//问题类型(kcyw=1,zttl=2,qtwt=3)
@property (nonatomic, assign) int hds;//回答数量
@property (nonatomic, strong) NSArray *cnList;//被采纳回答数组

+ (WDQuestionModel *)getQuestionModelWith:(NSDictionary *)dict;

@end

@interface WDAnswerPersonModel : NSObject

@property (nonatomic, copy) NSString *hdrID;//回答ID
@property (nonatomic, copy) NSString *hdr;//回答人
@property (nonatomic, copy) NSString *hdrIcon;//回答人头像
@property (nonatomic, copy) NSString *hdwz;//回答文字
@property (nonatomic, strong) NSArray *hdtpList;//回答图片列表
@property (nonatomic, copy) NSString *hdrq;//回答日期
@property (nonatomic, copy) NSString *sfcn;//是否采纳
@property (nonatomic, copy) NSString *xsjf;//悬赏积分
@property (nonatomic, copy) NSString *hdID;//

+ (WDAnswerPersonModel *)getQuestionPersonModelWith:(NSDictionary *)dict;

@end







