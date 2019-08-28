//
//  HWAddClassViewModel.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ViewModelClass.h"

///  添加班级viewmodel
@interface HWAddClassViewModel : ViewModelClass

///  获取所有的班级列表
- (void)fetchPublicAllClassroomList;
///  获取某个班级的所有小组
///
///  @param classId 班级id
- (void)fetchPublicSmallGroupWtih:(NSString *)classId;
///  获取班级的个人
///
///  @param classId 班级id
- (void)fetchPublicClassStudentWith:(NSString *)classId;

@end
