
//
//  HWOnlineNavView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWOnlineNavView.h"
#import "CenterTitleCollectionViewCell.h"

@interface HWOnlineNavView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  背景view
@property (nonatomic, strong) UIView *baselineView;
///  题目导航按钮
@property (nonatomic, strong) UILabel *titleLabel;
///  左边滑动按钮
@property (nonatomic, strong) UIButton *leftButton;

@property (nonatomic, strong) UIButton *shadeButton;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger data;
///  主观题
@property (nonatomic, copy) NSArray *subjectivityCount;
///  手势
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, assign) CGPoint panGestureStartLocation;

//标题数组
@property (nonatomic, copy) NSArray *titleArray;


@end

@implementation HWOnlineNavView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
        [self initGesture];
    }
    return self;
}

- (void)initView {
    self.shadeButton = [UIButton new];
    self.backgroundView = [UIView viewWithBackground:[UIColor hex:0xF6F6F6 alpha:1.0] alpha:1.0];
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.leftButton = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:25] title:@"\U0000e60f" titleColor:[UIColor grayColor] backgroundColor:[UIColor clearColor]];
    self.titleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.baselineView = [UIView viewWithBackground:[UIColor hex:0x000000 alpha:0.5] alpha:1.0];
    
    self.shadeButton.backgroundColor = [UIColor hex:0x000000 alpha:0.6];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.layout.minimumLineSpacing = 20;
    self.layout.minimumInteritemSpacing = 15;
    self.layout.itemSize = CGSizeMake(30, 30);
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor hex:0xF6F6F6 alpha:1.0];
    self.titleLabel.text = NSLocalizedString(@"题目导航", nil);
    [self.leftButton addTarget:self action:@selector(dismissNavAction) forControlEvents:UIControlEventTouchUpInside];
    [self.shadeButton addTarget:self action:@selector(dismissNavAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.shadeButton];
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.leftButton];
    [self.backgroundView addSubview:self.titleLabel];
    [self.backgroundView addSubview:self.collectionView];
    [self.backgroundView addSubview:self.baselineView];
}

- (void)initAutoLayout {
    [self.shadeButton zk_Fill:self insets:UIEdgeInsetsZero];
    [self.backgroundView zk_Fill:self insets:UIEdgeInsetsMake(0, 90, 0, 0)];
    [self.leftButton zk_AlignInner:ZK_AlignTypeTopLeft referView:self.backgroundView size:CGSizeMake(30, 40) offset:CGPointMake(10, 20)];
    [self.titleLabel zk_AlignInner:ZK_AlignTypeTopCenter referView:self.backgroundView size:CGSizeZero offset:CGPointMake(0, 30)];
    [self.baselineView zk_AlignInner:ZK_AlignTypeTopCenter referView:self.backgroundView size:CGSizeMake([UIScreen wd_screenWidth]-90, 1) offset:CGPointMake(0, 64)];
    [self.collectionView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self.backgroundView size:CGSizeMake([UIScreen wd_screenWidth]-90, [UIScreen wd_screenHeight]-64) offset:CGPointZero];
}

- (void)initGesture {
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self.backgroundView addGestureRecognizer:self.pan];
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)sender {
    
//    CGPoint location = [sender locationInView:self.backgroundView];
//    CGRect frame = self.backgroundView.frame;
//    CGFloat startX = 0;
//    CGFloat xOffset = [sender translationInView:self.backgroundView].x;
//    
//    switch (sender.state) {
//        case UIGestureRecognizerStateBegan:
//            self.panGestureStartLocation = location;
//            startX = frame.origin.x;
//            break;
//        case UIGestureRecognizerStateChanged:
//            if (xOffset > 0 && xOffset < [UIScreen wd_screenWidth] - 90) {
//                if (frame.origin.x) {
//        
//                }
//                frame.origin.x = xOffset + startX;
//            } else if (xOffset < 0 && xOffset > -([UIScreen wd_screenWidth] - 90)) {
//                if (frame.origin.x > [UIScreen wd_screenWidth] - 90) {
//                    frame.origin.x = xOffset + ([UIScreen wd_screenWidth] - 90);
//                }
//            }
//            self.backgroundView.frame = frame;
//            self.shadeButton.alpha = MIN(0.5 + frame.origin.x / ([UIScreen wd_screenWidth]-90), 1.0);
//            break;
//        case UIGestureRecognizerStateEnded:
//      
//            break;
//        default:
//            break;
//    }
    
    
    //CGRect frame = self.frame;
    //frame.origin.x = [sender translationInView:self.backgroundView].x;
    //if (frame.origin.x < 90) {
    //    return ;
    //}
    //self.backgroundView.frame = frame;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    [cell.rightView removeFromSuperview];
    cell.contentView.layer.cornerRadius = 15;
    cell.contentView.layer.masksToBounds = true;
    BOOL isSubjectivity = [self.subjectivityCount containsObject:[NSString stringWithFormat:@"%tu", indexPath.row + 1]] ? true : false;
    cell.label.textColor = self.currentIndex == indexPath.row ? [UIColor orangeColor] : (isSubjectivity ? [UIColor hex:0x319D8E alpha:1.0] : [UIColor grayColor]);
    cell.contentView.layer.borderColor = self.currentIndex == indexPath.row ? [UIColor orangeColor].CGColor : (isSubjectivity ? [UIColor hex:0x319D8E alpha:1.0].CGColor : [UIColor grayColor].CGColor);
    if (self.titleArray) {
        cell.label.text = [NSString stringWithFormat:@"%@", self.titleArray[indexPath.row]];
    }else {
        cell.label.text = [NSString stringWithFormat:@"%tu", indexPath.row + 1];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelect) {
        self.didSelect(indexPath.row);
    }
    [self dismissNavAction];
}

///  显示导航控制器
+ (HWOnlineNavView *)showNavViewActionWithCount:(NSInteger)count index:(NSInteger)index count:(NSArray *)array {
    HWOnlineNavView *obj = [HWOnlineNavView new];
    obj.data = count;
    obj.currentIndex = index;
    obj.subjectivityCount = array;
    [[UIApplication sharedApplication].keyWindow addSubview:obj];
    obj.frame = [UIScreen mainScreen].bounds;
    [obj showViewAction];
    return obj;
}

+ (HWOnlineNavView *)showNavViewActionWithCount:(NSInteger)count index:(NSInteger)index count:(NSArray *)array titleArray:(NSArray *)titleArray {
    HWOnlineNavView *obj = [HWOnlineNavView new];
    obj.data = count;
    obj.currentIndex = index;
    obj.subjectivityCount = array;
    obj.titleArray = titleArray;
    [[UIApplication sharedApplication].keyWindow addSubview:obj];
    obj.frame = [UIScreen mainScreen].bounds;
    [obj showViewAction];
    return obj;
}

- (void)showViewAction {
    self.shadeButton.alpha = 0.0;
    self.backgroundView.frame = CGRectMake([UIScreen wd_screenWidth], 0, [UIScreen wd_screenWidth]-90, [UIScreen wd_screenHeight]);
    [UIView animateWithDuration:0.5 animations:^{
        self.shadeButton.alpha = 1.0;
        self.backgroundView.frame = CGRectMake(90, 0, [UIScreen wd_screenWidth]-90, [UIScreen wd_screenHeight]);
    }];
}

///  消失导航控制器
- (void)dismissNavAction {

    [UIView animateWithDuration:0.5 animations:^{
        self.shadeButton.alpha = 0.0;
        self.backgroundView.frame = CGRectMake([UIScreen wd_screenWidth], 0, [UIScreen wd_screenWidth]-90, [UIScreen wd_screenHeight]);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
