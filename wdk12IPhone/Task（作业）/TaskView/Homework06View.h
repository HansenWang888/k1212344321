//
//  Homework06View.h
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkTaskView.h"

@interface Homework06TaskCell : UITableViewCell
@property (nonatomic, strong) HomeworkTaskView *taskView;
@property (nonatomic, strong) UIView *shadeView;

@end

@interface Homework06View : HomeworkTaskView

@property (nonatomic, copy) void(^didSel)(NSIndexPath *index);
@property (nonatomic, weak) Homework06TaskCell *tempCell;

@end

