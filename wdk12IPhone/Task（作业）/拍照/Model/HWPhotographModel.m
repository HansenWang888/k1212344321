//
//  HWPhotographModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPhotographModel.h"
#import "WDHTTPManager.h"

@implementation HWPhotographModel

+ (void)getPhotoraphTaskDetailWithZYID:(NSString *)zyId handler:(void(^)(NSArray *stData))handler {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getPZZYXQ.action"];
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:@{@"zyID" : zyId} urlString:url finished:^(NSDictionary *dict) {
        
        if (dict) {
            NSArray *zyfjList =  [NSDictionary mutableDictWith:dict][@"zyfjList"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *item in zyfjList) {
                HWPhotographModel *model = [HWPhotographModel new];
                [model setValuesForKeysWithDictionary:item];
                model.fjdz = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL, model.fjdz];
                
                model.stList = [NSMutableArray array];
                NSArray *stList = item[@"stList"];
                for (NSDictionary *it in stList) {
                    HWPhotographModel *m = [HWPhotographModel new];
                    [m setValuesForKeysWithDictionary:it];
                    m.fz = [NSString stringWithFormat:@"%@", it[@"fz"]];
                    [model.stList addObject:m];
                }
                [arrayM addObject:model];
            }
            handler(arrayM);
        } else {
            handler(nil);
        }
    }];
}

+ (void)getPhotoraphTaskFeedbackWithFbdxId:(NSString *)fbdxId fbdxlx:(NSString *)fbdxlx zyId:(NSString *)zyId handler:(void(^)(NSArray *xsData))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getJSPZZYFK.action"];
    NSDictionary *parameter = @{@"fbdxID" : fbdxId,
                                @"fbdxlx" : fbdxlx,
                                @"zyID" : zyId};
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            NSArray *zytjxx = [NSDictionary mutableDictWith:dict][@"zytjxx"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *item in zytjxx) {
                HWPhotographModel *model = [HWPhotographModel new];
                [model setValuesForKeysWithDictionary:item];
                
                model.fkList = [NSMutableArray array];
                NSArray *fkList = item[@"fkList"];
                for (NSDictionary *it in fkList) {
                    HWPhotographModel *mo = [HWPhotographModel new];
                    [mo setValuesForKeysWithDictionary:it];
                    mo.xsfjdz = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL, mo.xsfjdz];
                    
                    mo.stList = [NSMutableArray array];
                    NSArray *stList = it[@"stList"];
                    for (NSDictionary *d in stList) {
                        HWPhotographModel *m = [HWPhotographModel new];
                        [m setValuesForKeysWithDictionary:d];
                        if ([m.tmlxdm isEqualToString:@"03"]) {
                            m.zqdaan = [m.zqdaan isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : ([m.zqdaan isEqualToString:@"0"] ? NSLocalizedString(@"错", nil) : m.zqdaan);
                            m.xsdaan = [m.xsdaan isEqualToString:@"1"] ? NSLocalizedString(@"对", nil) : ([m.xsdaan isEqualToString:@"0"] ? NSLocalizedString(@"错", nil) : m.xsdaan);
                        }
                        [mo.stList addObject:m];
                    }
                    
                    
                    mo.pgfjList = [NSMutableArray array];
                    NSArray *pgfjList = it[@"pgfjList"];
                    for (NSDictionary *di in pgfjList) {
                        HWPhotographModel *mod = [HWPhotographModel new];
                        [mod setValuesForKeysWithDictionary:di];
                        [mo.pgfjList addObject:mod];
                    }
                    
                    [model.fkList addObject:mo];
                }
                [arrayM addObject:model];
            }
            handler(arrayM);
        } else {
            handler(nil);
        }
    }];
}

+ (void)phototgraphTaskFeedbackWithFbdxID:(NSString *)fbdxID jsID:(NSString *)jsID xsID:(NSString *)xsID zyID:(NSString *)zyID fkList:(NSArray *)fkList handler:(void(^)(BOOL))handler {
    
    NSString *fkListStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:fkList options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSDictionary *parameter = @{@"fbdxID" : fbdxID,
                                @"jsID" : jsID,
                                @"xsID" : xsID,
                                @"zyID" : zyID,
                                @"fkList" : fkListStr
                                };
    
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!updatePzZyFkxx.action"];
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        
        if ([dict[@"isSuccess"] isEqualToString:@"true"]) {
            handler(true);
        } else {
            handler(false);
        }
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

@end
