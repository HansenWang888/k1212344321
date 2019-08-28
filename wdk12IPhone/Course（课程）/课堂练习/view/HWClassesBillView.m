//
//  HWClassesBillView.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesBillView.h"
#import "HWClassesStudentList.h"
#import "DRQode.h"
#import "HWCExerciseEncodeManager.h"


@interface HWClassesBillViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) HWClassesStudentList *list;

@end
@interface HWClassesBillView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *leftCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *rightCollectionView;
@property (nonatomic, strong) NSMutableDictionary *XSListDict;
@property (nonatomic, strong) NSMutableDictionary *scanedDict;//序号
@property (nonatomic, strong) NSMutableArray *xsListM;
@property (nonatomic, strong) NSMutableArray *scanedListM;
@property (nonatomic, copy) NSArray *xsList;

@property (assign, nonatomic) BOOL isCanSubmit;

@end
@implementation HWClassesBillView

+ (instancetype)classesBillView {
    return [[[NSBundle mainBundle] loadNibNamed:@"HWClassesBillView" owner:nil options:nil] lastObject];
}
- (void)showDataWithStudentList:(NSArray *)list {
    self.xsList = list;
    for (HWClassesStudentList *student in list) {
        [self.XSListDict setObject:student forKey:student.kpbh];
    }
    [self.xsListM addObjectsFromArray:list];
    
    self.leftLabel.text = [NSString stringWithFormat:@"%@：%ld",NSLocalizedString(@"未扫描", nil) , list.count];
    self.rightLabel.text = [NSString stringWithFormat:@"%@：0", NSLocalizedString(@"已扫描", nil)];
    [self.leftCollectionView reloadData];
}
- (void)onlyShowScanedTable {
    [self.leftView removeFromSuperview];
    self.isCanSubmit = NO;
    [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
    }];
}
- (NSArray *)showScanedStudentList:(NSArray *)array {
    
    BOOL isChanged = NO;
    for (WD_Board_5x5 *board in array) {
        if (_isCanSubmit) {
            //能提交
           BOOL change = [self dealSubmitScanWithBoard:board];
            if (change) {
                isChanged = YES;
            }
        } else {
            //不能提交
           BOOL change = [self dealCanotSubmitScanWithBoard:board];
            if (change) {
                isChanged = YES;
            }
        }
    }
    if (isChanged) {
        return self.scanedDict.allValues;
    }
    return nil;
}
//处理提交页面的扫描
- (BOOL)dealSubmitScanWithBoard:(WD_Board_5x5 *)board {
    NSString *valueStr = [NSString stringWithFormat:@"%u",board.value];
    NSDictionary *encodeDict = [HWCExerciseEncodeManager exerciseEncodeShareManager].encodeDict[valueStr];
    if (encodeDict == nil) {
        return NO;
    }
    HWClassesStudentList *list = self.XSListDict[encodeDict[@"xh"]];
    HWClassesStudentList *xh = self.scanedDict[encodeDict[@"xh"]];
    BOOL isChanged = NO;
    if (list) {
        NSInteger index = [self.xsListM indexOfObject:list];
        [self.XSListDict removeObjectForKey:encodeDict[@"xh"]];
        [self.xsListM removeObject:list];
        [self.leftCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        self.leftLabel.text = [NSString stringWithFormat:@"%@：%ld", NSLocalizedString(@"未扫描", nil), self.XSListDict.allValues.count];
        
        list.isScan = YES;
        list.selectedContent = encodeDict[@"xx"];
        list.xh = encodeDict[@"xh"];
        list.valueEncode = valueStr;
        [self.scanedDict setObject:list forKey:encodeDict[@"xh"]];
        [self.scanedListM addObject:list];
        NSInteger rightIndex = self.scanedDict.allValues.count - 1;
        if (self.rightCollectionView.visibleCells.count == 0) {
            [self.rightCollectionView reloadData];
        } else {
            [self.rightCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:rightIndex inSection:0]]];
        }

        self.rightLabel.text = [NSString stringWithFormat:@"%@：%ld",NSLocalizedString(@"已扫描", nil), self.scanedDict.allValues.count];
        isChanged = YES;
    } else if (xh) {
       return [self dealCanotSubmitScanWithBoard:board];
    }
    return isChanged;
}
//处理不能提交页面的扫描
- (BOOL)dealCanotSubmitScanWithBoard:(WD_Board_5x5 *)board {
    NSString *valueStr = [NSString stringWithFormat:@"%u",board.value];
    NSDictionary *encodeDict = [HWCExerciseEncodeManager exerciseEncodeShareManager].encodeDict[valueStr];
    BOOL isChanged = NO;
    if (encodeDict) {
        HWClassesStudentList *list = self.scanedDict[encodeDict[@"xh"]];
        if (list == nil) {
            //创建
            list = [HWClassesStudentList new];
            list.isScan = YES;
            list.selectedContent = encodeDict[@"xx"];
            list.xh = encodeDict[@"xh"];
            list.valueEncode = valueStr;
            [self.scanedDict setObject:list forKey:encodeDict[@"xh"]];
            [self.scanedListM addObject:list];
            NSInteger index = self.scanedDict.allValues.count - 1;
            if (self.rightCollectionView.visibleCells.count == 0) {
                [self.rightCollectionView reloadData];
            } else {
                [self.rightCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            }
            self.rightLabel.text = [NSString stringWithFormat:@"%@：%ld",NSLocalizedString(@"已扫描", nil), self.scanedDict.allValues.count];
            isChanged = YES;
        } else {
            //更新
            if (![list.valueEncode isEqualToString:encodeDict[@"bmz"]]) {
                list.selectedContent = encodeDict[@"xx"];
                list.xh = encodeDict[@"xh"];
                list.valueEncode = valueStr;
                NSInteger index = [self.scanedListM indexOfObject:list];
                [self.rightCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                isChanged = YES;
            }
        }
    }
    return isChanged;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftCollectionView.dataSource = self;
    self.leftCollectionView.delegate = self;
    self.rightCollectionView.dataSource = self;
    self.rightCollectionView.delegate = self;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self.rightCollectionView.collectionViewLayout = layout;
    UICollectionViewFlowLayout *leftLayout = [UICollectionViewFlowLayout new];
    self.leftCollectionView.collectionViewLayout = leftLayout;
    self.XSListDict = @{}.mutableCopy;
    self.scanedDict = @{}.mutableCopy;
    [self.leftCollectionView registerClass:[HWClassesBillViewCell class] forCellWithReuseIdentifier:@"billCell"];
    [self.rightCollectionView registerClass:[HWClassesBillViewCell class] forCellWithReuseIdentifier:@"billCell"];
    self.isCanSubmit = YES;
    self.xsListM = @[].mutableCopy;
    self.scanedListM = @[].mutableCopy;

}
- (void)resetData {
    [self.scanedDict removeAllObjects];
    for (HWClassesStudentList *student in self.xsList) {
        student.isScan = NO;
        student.selectedContent = nil;
        student.xh = nil;
        student.valueEncode = nil;
        [self.XSListDict setObject:student forKey:student.kpbh];
    }
    [self.scanedListM removeAllObjects];
    [self.xsListM removeAllObjects];
    [self.xsListM addObjectsFromArray:self.xsList];
    [self.leftCollectionView reloadData];
    [self.rightCollectionView reloadData];
    self.leftLabel.text = [NSString stringWithFormat:@"%@：%ld",NSLocalizedString(@"未扫描", nil), self.XSListDict.allValues.count];
    self.rightLabel.text = [NSString stringWithFormat:@"%@：0", NSLocalizedString(@"已扫描", nil)];
}
- (NSArray *)getScanedStudents {
    return self.scanedDict.allValues;
}
#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.leftCollectionView) {
        return self.xsListM.count;
    }
    return self.scanedListM.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWClassesBillViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"billCell" forIndexPath:indexPath];
    HWClassesStudentList *student = nil;
    if (collectionView == self.leftCollectionView) {
        student = self.xsListM[indexPath.row];
    } else {
        student = self.scanedListM[indexPath.row];
    }
    cell.list = student;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.leftCollectionView) {
        
        return CGSizeMake(self.leftCollectionView.w - 20, 30);
    }
    return CGSizeMake(100, 25);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
@end

@implementation HWClassesBillViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.nameLabel.frame = self.contentView.bounds;
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}
- (void)setList:(HWClassesStudentList *)list {
    _list = list;
    NSDictionary *colorDict =  @{@"A":COLOR_Creat(57, 199, 200, 1),
                                 @"B":COLOR_Creat(253, 185, 132, 1),
                                 @"C":COLOR_Creat(214, 123, 129, 1),
                                 @"D":COLOR_Creat(152, 180, 88, 1)};
    UIColor *color = colorDict[list.selectedContent];
    if (color == nil) {
        color = [UIColor grayColor];
    }
    self.nameLabel.backgroundColor = color;
    if (list.xsxm == nil) {
        self.nameLabel.text = [NSString stringWithFormat:@"#%@  %@",list.xh,list.selectedContent];
    } else if (list.selectedContent.length == 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@",list.xsxm];
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@  %@",list.xsxm,list.selectedContent];
    }
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}
@end
