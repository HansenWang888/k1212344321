//
//  SchedulerViewController.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SchedulerControllerDlegate <NSObject>
//传出查询的条件，多个班级或某个班级
- (void)schedulerForClassesData:(id )anyData;
@end

@interface SchedulerViewController : UIViewController

@property (nonatomic, weak) id<SchedulerControllerDlegate> schedulerDelegate;


@end
