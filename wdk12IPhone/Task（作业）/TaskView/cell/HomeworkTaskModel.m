//
//  HomeworkTaskModel.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkTaskModel.h"

@implementation HomeworkTaskModel

+ (instancetype)taskModelWithDict:(NSDictionary *)dict {
    HomeworkTaskModel *model = [HomeworkTaskModel new];
    model.isSubmit = true;
    model.pxbh = [NSString stringWithFormat:@"%@", dict[@"pxbh"]];
    model.fz = [NSString stringWithFormat:@"%ld", [dict[@"fz"] integerValue]];
    model.stID = dict[@"stID"];
    model.stlx = dict[@"stlx"];
    if (!model.stlx) {
        model.stlx = dict[@"tmlx"];
    }
    model.zkg = dict[@"stnr"][@"zkg"];
    model.stjx = dict[@"stnr"][@"stjx"];
    model.stda = dict[@"stnr"][@"stda"];
    model.zsdmc = dict[@"stnr"][@"zsdmc"];
    model.stxux = dict[@"stnr"][@"stxux"];
    model.sttg = dict[@"stnr"][@"sttg"];
    model.mystda = dict[@"stnr"][@"hdda"];
        
    NSMutableArray *arrayM = @[].mutableCopy;
    NSArray *xtList = dict[@"stnr"][@"stxtList"];
    for (NSDictionary *dict in xtList) {
        HomeworkTaskModel *xt = [HomeworkTaskModel new];
        xt.isSubmit = true;
        xt.pxbh = @"";//[NSString stringWithFormat:@"%@", dict[@"pxbh"]];
        xt.stlx = dict[@"xtlx"];
        xt.stID = dict[@"xtID"];
        xt.fz = [NSString stringWithFormat:@"%ld", [dict[@"fz"] integerValue]];

        xt.sttg = dict[@"xtnr"][@"xttg"];
        xt.zkg = dict[@"xtnr"][@"zkg"];
        xt.stjx = dict[@"xtnr"][@"xtjx"];
        xt.stxux = dict[@"xtnr"][@"xtxux"];
        xt.stda = dict[@"xtnr"][@"xtda"];
        xt.zsdmc = model.zsdmc;

        if ([xt.stlx isEqualToString:@"03"]) {
            xt.stda = [dict[@"xtnr"][@"xtda"] isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil);
        }
        xt.mystdf = [NSString stringWithFormat:@"%@", dict[@"mystdf"] ? dict[@"mystdf"] : @""];
        xt.mydasfzq = dict[@"mydasfzq"];
        xt.mystda = dict[@"mystda"];
        [arrayM addObject:xt];
    }
    model.stxtList = arrayM.copy;
    
    if (!model.mystda) {
        model.mystda = dict[@"mystda"];
    }
    
    if ([model.stlx isEqualToString:@"03"]) {
        model.stda = [dict[@"stnr"][@"stda"] isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil);
    }
    model.mydasfzq = dict[@"mydasfzq"];
    model.mystdf = [NSString stringWithFormat:@"%@", dict[@"mystdf"] ? dict[@"mystdf"] : @""];
    
    model.sjID = dict[@"sjID"];
    
    return model;
}



+ (instancetype)task06ModelWithDict:(NSDictionary *)dict {
    HomeworkTaskModel *xt = [HomeworkTaskModel new];
    xt.isSubmit = true;
    xt.pxbh = [NSString stringWithFormat:@"%@", dict[@"pxbh"]];//[NSString stringWithFormat:@"%@", dict[@"pxbh"]];
    xt.stlx = dict[@"xtlx"];
    xt.stID = dict[@"xtID"];
    xt.fz = [NSString stringWithFormat:@"%ld", [dict[@"fz"] integerValue]];
    
    xt.sttg = dict[@"xtnr"][@"xttg"];
    xt.zkg = dict[@"xtnr"][@"zkg"];
    xt.stjx = dict[@"xtnr"][@"xtjx"];
    xt.stxux = dict[@"xtnr"][@"xtxux"];
    xt.stda = dict[@"xtnr"][@"xtda"];
    xt.zsdmc = dict[@"stnr"][@"zsdmc"];
    
    if ([xt.stlx isEqualToString:@"03"]) {
        xt.stda = [dict[@"xtnr"][@"xtda"] isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil);
    }
    xt.mystdf = [NSString stringWithFormat:@"%@", dict[@"mystdf"] ? dict[@"mystdf"] : @""];
    xt.mydasfzq = dict[@"mydasfzq"];
    xt.mystda = dict[@"mystda"];
    return xt;
}

+ (instancetype)practiceTaskModelWithDict:(NSDictionary *)dict {
    HomeworkTaskModel *model = [HomeworkTaskModel new];
    model.isSubmit = true;
    model.pxbh = [NSString stringWithFormat:@"%@", dict[@"pxbh"]];
    model.stID = dict[@"stID"];
    model.stlx = dict[@"stlx"];
    if (!model.stlx) {
        model.stlx = dict[@"tmlx"];
    }
    model.zkg = dict[@"stnr"][@"zkg"];
    model.stjx = dict[@"stnr"][@"stjx"];
    model.stda = dict[@"stnr"][@"stda"];
    model.zsdmc = dict[@"stnr"][@"zsdmc"];
    model.stxux = dict[@"stnr"][@"stxux"];
    model.sttg = dict[@"stnr"][@"sttg"];
    model.mystda = dict[@"stnr"][@"hdda"];
        
    NSMutableArray *arrayM = @[].mutableCopy;
    NSArray *xtList = dict[@"stnr"][@"stxtList"];
    for (NSDictionary *dict in xtList) {
        HomeworkTaskModel *xt = [HomeworkTaskModel new];
        xt.isSubmit = true;
        xt.pxbh = @"";
        xt.stlx = dict[@"xtlx"];
        xt.stID = dict[@"xtID"];
        
        xt.sttg = dict[@"xtnr"][@"xttg"];
        xt.zkg = dict[@"xtnr"][@"zkg"];
        xt.stjx = dict[@"xtnr"][@"xtjx"];
        xt.stxux = dict[@"xtnr"][@"xtxux"];
        xt.stda = dict[@"xtnr"][@"xtda"];
        xt.zsdmc = model.zsdmc;
        xt.mydasfzq = [dict[@"xtnr"][@"hdda"]isEqualToString:dict[@"xtnr"][@"xtda"]] ? @"1" : @"0";
        if ([xt.stlx isEqualToString:@"03"]) {
            xt.stda = [dict[@"xtnr"][@"xtda"] isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil);
            xt.mydasfzq = [dict[@"xtnr"][@"hdda"]isEqualToString:[xt.stda isEqualToString:NSLocalizedString(@"对", nil)] ? @"1" : @"0"] ? @"1" : @"0";
        }
        xt.mystda = dict[@"xtnr"][@"hdda"];
//        xt.mystdf = [NSString stringWithFormat:@"%@", dict[@"mystdf"] ? dict[@"mystdf"] : @""];
        xt.fz = dict[@"fz"];
        [arrayM addObject:xt];
    }
    model.stxtList = arrayM.copy;
    model.mystdf = [NSString stringWithFormat:@"%@", dict[@"mystdf"] ? dict[@"mystdf"] : @""];
    
    model.mydasfzq = [dict[@"stnr"][@"hdda"] isEqualToString:dict[@"stnr"][@"stda"]] ? @"1" : @"0";
    if ([model.stlx isEqualToString:@"03"]) {
        model.stda = [dict[@"stnr"][@"stda"] isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : NSLocalizedString(@"错", nil);
        model.mydasfzq = [dict[@"stnr"][@"hdda"] isEqualToString:[model.stda isEqualToString:NSLocalizedString(@"对", nil)] ? @"1" : @"0"] ? @"1" : @"0";
    }
    
    model.sjID = dict[@"sjID"];
    
    return model;
}

@end
