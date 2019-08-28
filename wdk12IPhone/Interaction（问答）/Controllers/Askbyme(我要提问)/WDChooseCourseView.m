//
//  WDChooseCourseView.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDChooseCourseView.h"
#import "WDCourseDetailModel.h"

@interface WDChooseCourseView ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) WDCourseDetailModel *selectedModel;

@end

@implementation WDChooseCourseView

- (void)awakeFromNib {
    [super awakeFromNib];
    _courses = @[];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setCourses:(NSArray *)courses {
    _courses = courses;
    [self.tableView reloadData];
    self.tableView.tableFooterView = [UIView new];
}

- (IBAction)cancleClicked:(id)sender {
    if (_cancleBlock) {
        _cancleBlock();
    }
}
- (IBAction)confirmClicked:(id)sender {
    if (_confirmBlock) {
        _confirmBlock(self.selectedModel);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    WDCourseDetailModel *model = self.courses[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@%@",model.km,model.nj,model.cb,model.jcbbmc];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WDCourseDetailModel *model = self.courses[indexPath.row];
    self.selectedModel  = model;
}

@end
