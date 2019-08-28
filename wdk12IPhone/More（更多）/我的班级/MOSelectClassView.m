//
//  MOSelectClassView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MOSelectClassView.h"

@interface MOSelectClassView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

///  选择后面的view
@property (nonatomic, strong) UIView *selectView;
///  遮罩按钮
@property (nonatomic, strong) UIButton *shadeButton;
///  确定按钮
@property (nonatomic, strong) UIButton *trueButton;
///  取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) NSArray *data;

@property (nonatomic, assign) NSIndexPath *indexPath;

@end

@implementation MOSelectClassView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.trueButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"确定", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor orangeColor]];
    self.cancelButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"取消", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor grayColor]];
    self.shadeButton = [UIButton new];
    self.shadeButton.backgroundColor = [UIColor hex:0x000000 alpha:0.4];
    self.shadeButton.alpha = 0.0;
    self.selectView = [UIView viewWithBackground:[UIColor whiteColor] alpha:1.0];
    [self.shadeButton addTarget:self action:@selector(dismissTimeSelectView) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel = [UILabel labelBackgroundColor:[UIColor hex:0x30B6BC alpha:1.0] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.titleLabel.text = [NSString stringWithFormat:@"  %@", NSLocalizedString(@"选择年级", nil)];
    
    self.cancelButton.tag = 1;
    [self.trueButton addTarget:self action:@selector(inputButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(inputButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.selectView.clipsToBounds = true;
    
    [self addSubview:self.shadeButton];
    [self addSubview:self.selectView];
    [self.selectView addSubview:self.titleLabel];
    [self.selectView addSubview:self.tableView];
    [self.selectView addSubview:self.trueButton];
    [self.selectView addSubview:self.cancelButton];
}

- (void)initAutoLayout {
    [self.shadeButton zk_Fill:self insets:UIEdgeInsetsZero];
    [self.selectView zk_AlignVertical:ZK_AlignTypeCenterCenter referView:self size:CGSizeMake(300, 300) offset:CGPointZero];
    [self.titleLabel zk_AlignInner:ZK_AlignTypeTopCenter referView:self.selectView size:CGSizeMake(280, 45) offset:CGPointMake(0, 10)];
    [self.tableView zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.selectView size:CGSizeMake(280, 200) offset:CGPointZero];
    [self.cancelButton zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.selectView size:CGSizeMake(135, 45) offset:CGPointMake(10, -10)];
    [self.trueButton zk_AlignInner:ZK_AlignTypeBottomRight referView:self.selectView size:CGSizeMake(135, 45) offset:CGPointMake(-10, -10)];
}

#pragma mark - tableView delegate datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(self.data[indexPath.row], nil);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
}

#pragma mark - custom action
+ (MOSelectClassView *)showClassSelectWith:(UIView *)v title:(NSString *)title data:(NSArray *)data {
    MOSelectClassView *dv = [MOSelectClassView new];
    [v addSubview:dv];
    dv.frame = v.bounds;
    dv.titleLabel.text = title;
    dv.data = data;
    dv.selectView.bounds = CGRectMake(0, 0, 300, 0);
    dv.shadeButton.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        dv.shadeButton.alpha = 1.0;
        dv.selectView.bounds = CGRectMake(0, 0, 300, 300);
    }];
    return dv;
}

- (void)dismissTimeSelectView {
    [UIView animateWithDuration:0.5 animations:^{
        self.shadeButton.alpha = 0.0;
        self.selectView.bounds = CGRectMake(0, 0, 300, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//1取消 2确定
- (void)inputButtonClick:(UIButton *)sender {
    if (sender.tag == 1) { // 取消
        [self dismissTimeSelectView];
    } else { // 确定
        if (!self.indexPath) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"您还未选择任何一项", nil)];
            return ;
        }
        if (self.didSel) {
            self.didSel(self.indexPath);
            [self dismissTimeSelectView];
        }
    }
}

@end
