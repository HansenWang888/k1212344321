//
//  RosterViewModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ViewModelClass.h"

@class ClassModel;

@interface RosterViewModel : ViewModelClass

- (void)fetchPublicRosterWithModel:(ClassModel *)classModel;

///  退出班级方法
///
///  @param jsjs    教师角色
///  @param bjId    班级id
///  @param km      科目
///  @param handler 回调
+ (void)exitClassActionJsjs:(NSString *)jsjs bjId:(NSString *)bjId km:(NSString *)km handler:(void(^)(BOOL isSuccess))handler;

@end
