//
//  WDAnswerDetailModel.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDAnswerDetailModel : NSObject

@property (nonatomic, copy) NSString *hdrID;
@property (nonatomic, copy) NSString *hdID;
@property (nonatomic, copy) NSString *hdwz;
@property (nonatomic, copy) NSString *hdr;
@property (nonatomic, copy) NSString *hdfwbnr;
@property (nonatomic, copy) NSString *hdhjID;
@property (nonatomic, copy) NSString *hdrq;
@property (nonatomic, copy) NSString *xsjf;
@property (nonatomic, strong) NSArray *hdtpList;
@property (nonatomic, copy) NSString *hdzlx;
@property (nonatomic, strong) NSArray *hfxxList;
@property (nonatomic, copy) NSString *hdrIcon;
@property (nonatomic, copy) NSString *sfcn;

//回复
@property (nonatomic, copy) NSString *hfrIcon;
@property (nonatomic, copy) NSString *hfnr;
@property (nonatomic, copy) NSString *hfrq;
@property (nonatomic, copy) NSString *hfr;

+ (WDAnswerDetailModel *)getAnswerDetailModelWith:(NSDictionary *)dict;


@end
