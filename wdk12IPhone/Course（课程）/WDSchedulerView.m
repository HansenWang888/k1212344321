//
//  WDSchedulerView.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDSchedulerView.h"

@interface WDSchedulerView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrayList;


@end

@implementation WDSchedulerView



- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}

- (NSArray *)arrayList {
    if (!_arrayList) {
        _arrayList = [WDSchedulerView deleRepeatClasses];
    }
    return _arrayList;
}
+ (NSArray *)deleRepeatClasses {
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

+ (CGFloat)getHeight {
    NSArray *array = [WDSchedulerView deleRepeatClasses];
    return (1 + array.count > 5 ? 5 : 1 + array.count) * 44 + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayList.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"我的课表", nil);
        return cell;
    }
    cell.textLabel.text = self.arrayList[indexPath.row - 1][@"bjmc"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if (self.clickedBlock) {
            //传入MY代表是查找我的课表
            self.clickedBlock(@{@"key" : @"MY"});
//            [self.schedulerDelegate schedulerForClassesData:@{@"key" : @"MY"}];
        }
        return;
    }
    NSDictionary *dict = self.arrayList[indexPath.row - 1];
    if (self.clickedBlock) {
        self.clickedBlock(dict);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


- (void)drawRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 10, width,height -10) cornerRadius:3.0];
    
    [path moveToPoint:CGPointMake(width/2.0-7, 10)];
    [path addLineToPoint:CGPointMake(width/2.0, 0)];
    [path addLineToPoint:CGPointMake(width/2.0+7, 10)];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    [[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] set];
    
    [path fill];
}

@end
