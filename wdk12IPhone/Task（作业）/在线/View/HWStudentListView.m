//
//  HWStudentListController.m
//  demo
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWStudentListView.h"
#import "HWOnlieStudentCell.h"
#import "HWDragView.h"

@interface HWStudentListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
///  是否是小题
@property (nonatomic, assign) BOOL isSmallTest;
///  小题索引
@property (nonatomic, assign) NSInteger index;
///  查找的试题id
@property (nonatomic, strong) NSString *stID;

@end

@implementation HWStudentListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initTableView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    self.dragView = [HWDragView new];
    [self addSubview:self.dragView];
}

- (void)initTableView {
    self.tableView = [UITableView tableViewWithSuperView:self dataSource:self backgroundColor:[UIColor hex:0xEFEFEF alpha:1.0] separatorStyle:UITableViewCellSeparatorStyleNone registerCell:[HWOnlieStudentCell class] cellIdentifier:@"HWOnlieStudentCell"];
    
    [self.dragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.offset(22);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.mas_equalTo(self.dragView.mas_bottom);
    }];
    
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor clearColor];
    v.frame = CGRectMake(0, 0, [UIScreen wd_screenWidth], 40);
    UILabel *label = [UILabel labelBackgroundColor:[UIColor clearColor] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    label.text = NSLocalizedString(@"学生提交", nil);
    [v addSubview:label];
    [label zk_AlignInner:ZK_AlignTypeCenterCenter referView:v size:CGSizeZero offset:CGPointZero];
    self.tableView.tableHeaderView = v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWOnlieStudentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWOnlieStudentCell" forIndexPath:indexPath];
    cell.taskModel = self.taskModel;
//    [cell setValueForDataSource:self.dataSource[indexPath.row]];
    [cell setValueForDataSource:self.dataSource[indexPath.row] type:self.isSmallTest xtIndex:self.index stID:self.stID];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelect) {
        self.didSelect(indexPath);
    }
}

- (void)setValueForDataSource:(NSArray *)data type:(BOOL)type xtIndex:(NSInteger)index stID:(NSString *)stID {
    self.dataSource = data;
    self.isSmallTest = type;
    self.index = index;
    self.stID = stID;
    [self.tableView reloadData];
}

@end
