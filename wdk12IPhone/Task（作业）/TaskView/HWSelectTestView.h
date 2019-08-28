//
//  HWSelectTestView.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  选题view
@interface HWSelectTestView : UIView

///  题目导航按钮
@property (nonatomic, strong) UIButton *topicNavButton;
///  当前选中的cell
@property (nonatomic, assign) NSInteger currentSel;

///  题目总数量
@property (nonatomic, assign) NSInteger count;

//+ (HWSelectTestView *)showSelectTestViewWith:(NSInteger)count currentIndex:(NSInteger)index didSel:(void(^)(NSInteger row))didSel;
+ (HWSelectTestView *)showSelectTestViewWith:(UIView *)view count:(NSInteger)count currentIndex:(NSInteger)index didSel:(void(^)(NSInteger row))didSel;

@end
