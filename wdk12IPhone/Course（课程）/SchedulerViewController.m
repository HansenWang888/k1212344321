//
//  SchedulerViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "SchedulerViewController.h"
#import "WDUser.h"
#import "WDTeacher.h"
#import "CourseViewController.h"
#import "WDStudent.h"
typedef struct {
    unsigned int didReceiveData : 1;
    
} delegateFlags;
@interface SchedulerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, assign) delegateFlags flag;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SchedulerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}
- (void)setSchedulerDelegate:(id<SchedulerControllerDlegate>)schedulerDelegate {
    
    _schedulerDelegate = schedulerDelegate;
    _flag.didReceiveData = [_schedulerDelegate respondsToSelector:@selector(schedulerForClassesData:)];
}
- (NSArray *)arrayList {
    if (!_arrayList) {
        _arrayList = [self deleRepeatClasses];
        
    }
    return _arrayList;
}
- (NSArray *)deleRepeatClasses {
    //过滤重复班级
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *classesDict in [WDTeacher sharedUser].teacherList) {
        NSArray *array = classesDict[@"bjList"];
        for (NSDictionary *dict in array) {
            if (![arrayM containsObject:dict]) {
                [arrayM addObject:dict];
            }
        }
    }
    return arrayM.copy;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayList.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schedulerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"schedulerCell"];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"我的课表";
        return cell;
    }
    cell.textLabel.text = self.arrayList[indexPath.row - 1][@"bjmc"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        if (self.flag.didReceiveData) {
            //传入MY代表是查找我的课表
            [self.schedulerDelegate schedulerForClassesData:@{@"key" : @"MY"}];
        }
        return;
    }
    NSDictionary *dict = self.arrayList[indexPath.row - 1];
    if (self.flag.didReceiveData) {
        [self.schedulerDelegate schedulerForClassesData:dict];
    }
}

@end
