//
//  HWPhotographTaskController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPhotographTaskController.h"
#import "HWShowPictureTaskView.h"
#import "CenterTitleCollectionViewCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "HWPhotographCorrectCell.h"
#import "CenterTextFieldCell.h"
#import "HWPhotographModel.h"
#import "HWTaskModel.h"

@interface HWPhotographTaskController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) HWShowPictureTaskView *pictureTaskView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSMutableArray *dataSource;
///  当前试题数据
@property (nonatomic, strong) HWPhotographModel *currentSTData;
///  反馈按钮
@property (nonatomic, strong) UIButton *feedbackButton;

@property (nonatomic, strong) NSLayoutConstraint *collectionViewH;

@property (nonatomic, weak) UIButton *tempBtn;

@property (nonatomic, weak) UITextField *tempTextField;

@end

@implementation HWPhotographTaskController

- (void)loadView {
    self.view = [TPKeyboardAvoidingScrollView new];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.bounds = [UIScreen mainScreen].bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initAutoLayout];
    [self loadData];
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
    self.pictureTaskView = [HWShowPictureTaskView new];
    self.pictureTaskView.superViewController = self;
    [self.view addSubview:self.pictureTaskView];
    WEAKSELF(self);
    self.pictureTaskView.currentPage = ^(NSInteger page) {
        weakSelf.currentSTData = weakSelf.xsData.fkList[page];
        [weakSelf.collectionView reloadData];
    };
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    [self.collectionView registerClass:[HWPhotographCorrectCell class] forCellWithReuseIdentifier:@"HWPhotographCorrectCell"];
    [self.collectionView registerClass:[CenterTextFieldCell class] forCellWithReuseIdentifier:@"CenterTextFieldCell"];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor hex:0xFEFFFF alpha:1.0];
    self.title = [self.xsData.xsxm stringByAppendingString:NSLocalizedString(@"的作业", nil)];
    
    self.feedbackButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"反馈", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x2092EE alpha:1]];
    self.feedbackButton.layer.cornerRadius = 3;
    self.feedbackButton.layer.masksToBounds = true;
    [self.view addSubview:self.feedbackButton];
    [self.feedbackButton addTarget:self action:@selector(taskFeedbackAction) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)initAutoLayout {
    CGFloat w = [UIScreen wd_screenWidth];
    CGFloat h = [UIScreen wd_screenHeight];
    CGFloat ph = (h - 64) * 0.5 - 50;
    [self.pictureTaskView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake(w - 20, ph) offset:CGPointMake(10, 74)];
    NSArray *cons = [self.collectionView zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.pictureTaskView size:CGSizeMake(w - 20, [UIScreen wd_screenHeight] - ph - 50 - 64) offset:CGPointMake(0, 10)];
    self.collectionViewH = [self.collectionView zk_Constraint:cons attribute:NSLayoutAttributeHeight];
    [self.feedbackButton zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.collectionView size:CGSizeMake(w - 20, 30) offset:CGPointMake(0, 10)];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.currentSTData.stList.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(([UIScreen wd_screenWidth]-20)/5, 35);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    cell.label.font = [UIFont systemFontOfSize:15];
    if (indexPath.section == 0) {
        cell.label.text = self.dataSource[indexPath.row];
        cell.label.textColor = [UIColor blackColor];
        cell.contentView.backgroundColor = [UIColor hex:0x000000 alpha:0.1];
    } else {
        cell.label.textColor = [UIColor hex:0x999999 alpha:1.0];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        HWPhotographModel *model = self.currentSTData.stList[indexPath.section - 1];
        NSArray *correntTx = @[@"02", @"05"];// 可批改题型
        if (indexPath.row == 0) {
            NSDictionary *stlx = @{@"0101" : NSLocalizedString(@"单选题", nil), @"0102" : NSLocalizedString(@"多选题", nil), @"02" : NSLocalizedString(@"填空题", nil), @"03" : NSLocalizedString(@"判断题", nil), @"05" : NSLocalizedString(@"简答题", nil)};
            cell.label.text = [NSString stringWithFormat:@"%@.(%@)", model.pxbh, stlx[model.tmlxdm]];
        } else if (indexPath.row == 1) {
            cell.label.text = [correntTx containsObject:model.tmlxdm] ? @"" : model.zqdaan;
        } else if (indexPath.row == 2) {
            cell.label.text = [correntTx containsObject:model.tmlxdm] ? @"" : model.xsdaan;
        } else if (indexPath.row == 3) {
            if ([correntTx containsObject:model.tmlxdm]) {
                CenterTextFieldCell *cel = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTextFieldCell" forIndexPath:indexPath];
                cel.textField.keyboardType = UIKeyboardTypeNumberPad;
//                cel.textField.text = model.df;
                NSString *str = [NSString stringWithFormat:@"%@/%@", model.fz, model.df];
                cel.textField.text = str;
                NSRange range1 = [cel.textField.text rangeOfString:@"/"];
                NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:cel.textField.text];
                [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attrM.length)];
                [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, range1.location+1)];
                cel.textField.attributedText = attrM;
                [cel.textField addTarget:self action:@selector(textFieldBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
//                cel.textField.delegate = self;
                [cel.textField addTarget:self action:@selector(saveCurrentScoreAction:) forControlEvents:UIControlEventEditingChanged];
                cel.textField.tag = indexPath.section;
                return cel;
            } else {
                cell.label.text = [NSString stringWithFormat:@"%ld/%ld", model.fz.integerValue, model.df.integerValue];
                NSRange range1 = [cell.label.text rangeOfString:@"/"];
                NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:cell.label.text];
                [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attrM.length)];
                [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, range1.location+1)];
                cell.label.attributedText = attrM;
            }
            
        } else if (indexPath.row == 4) {
            HWPhotographCorrectCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HWPhotographCorrectCell" forIndexPath:indexPath];
            model.ptjg = [correntTx containsObject:model.tmlxdm] ? @"" : model.ptjg;
            cell.imageView.image = [UIImage imageNamed:[model.ptjg isEqualToString:@"1"] ?
                                    @"hw_photograph_true" : ([model.ptjg isEqualToString:@"0"] ? @"hw_photograph_false" : @"")];
            return cell;
        }
        
    }
    return cell;
}

- (void)loadData {
    
    NSArray *temp = self.xsData.fkList.copy; // 复制
    [self.xsData.fkList removeAllObjects]; // 清空
    [self.xsData.stList removeAllObjects];
    
    for (HWPhotographModel *item in self.stData) {
        BOOL isContain = true;
        
        for (HWPhotographModel *it in temp) {
            if ([item.fjID isEqualToString:it.zyfjID]) {
                
                NSArray *stList = item.stList.copy;
                [item.stList removeAllObjects];
                for (HWPhotographModel *stItem in stList) {
                    BOOL isCon = true;
                    
                    for (HWPhotographModel *i in it.stList) {
                        if ([i.stID isEqualToString:stItem.stID]) {
                            i.pxbh = stItem.pxbh;
                            [item.stList addObject:i];
                            i.fz = stItem.fz;
                            isCon = false;
                            break;
                        }
                    }
                    if (isCon) {
                        [item.stList addObject:stItem];
                        [it.stList addObject:stItem];
                    }
                }
                
                [self.xsData.fkList addObject:it];
                isContain = false;
                break;
            }
        }
        if (isContain) {
            item.xsfjdz = item.fjdz;
            [self.xsData.fkList addObject:item];
        }
    }
    [self.pictureTaskView setValueForDataSource:self.xsData];
    self.currentSTData = self.xsData.fkList.firstObject;
    [self.collectionView reloadData];
}

- (void)setCurrentSTData:(HWPhotographModel *)currentSTData {
    _currentSTData = currentSTData;
    self.collectionViewH.constant = (currentSTData.stList.count + 1) * 35;
    
    CGFloat ph = self.collectionViewH.constant + 84 + ([UIScreen wd_screenHeight] - 64) * 0.5;
    CGSize size = CGSizeMake([UIScreen wd_screenWidth], ph);
    ((UIScrollView *)self.view).contentSize = size;
}

- (void)textFieldBeginEdit:(UITextField *)textField {
    NSArray *strM = [textField.text componentsSeparatedByString:@"/"];
    if ([strM.lastObject isEqualToString:@"0"]) {
        NSMutableString *strM = textField.text.mutableCopy;
        [strM deleteCharactersInRange:NSMakeRange(strM.length - 1, 1)];
        textField.text = strM;
        NSRange range1 = [textField.text rangeOfString:@"/"];
        NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:textField.text];
        [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attrM.length)];
        [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, range1.location+1)];
        textField.attributedText = attrM;
    }
}

///  保存当前得分方法
- (void)saveCurrentScoreAction:(UITextField *)textField {
    self.tempTextField = textField;
    HWPhotographModel *model = self.currentSTData.stList[textField.tag - 1];
    NSArray *strM = [textField.text componentsSeparatedByString:@"/"];
    model.df = strM.lastObject;

    if (![textField.text containsString:@"/"]) {
        textField.text = [NSString stringWithFormat:@"%@/", textField.text];
    }
    if ([strM.lastObject integerValue] > [strM.firstObject integerValue]) {
        NSMutableString *strM = textField.text.mutableCopy;
        [strM deleteCharactersInRange:NSMakeRange(strM.length - 1, 1)];
        textField.text = strM;
        [SVProgressHUD showErrorWithStatus:@"设置的分数超过了该题的分值"];
    }
    
    NSRange range1 = [textField.text rangeOfString:@"/"];
    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attrM.length)];
    [attrM addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, range1.location+1)];
    textField.attributedText = attrM;
}

///  作业反馈方法
- (void)taskFeedbackAction {
    
    NSMutableArray *fkListM = [NSMutableArray arrayWithCapacity:self.xsData.fkList.count];
    NSArray *correntTx = @[@"02", @"05"];// 可批改题型
    for (HWPhotographModel *item in self.xsData.fkList) {
        NSMutableArray *stListM = [NSMutableArray arrayWithCapacity:item.stList.count];
        
        for (HWPhotographModel *it in item.stList) {
            if ([correntTx containsObject:it.tmlxdm]) {
                NSDictionary *dict = @{@"df" : [NSString stringWithFormat:@"%ld", it.df.integerValue],
                                       @"ptjg" : it.ptjg ? it.ptjg : @"",
                                       @"stID" : it.stID};
                [stListM addObject:dict];
            }
        }
        
        NSMutableArray *pgfjList = [NSMutableArray arrayWithCapacity:item.pgfjList.count];
        
        for (HWPhotographModel *mm in item.pgfjList) {
            
                NSDictionary *dict = @{@"fjdx" : mm.fjdx,
                                       @"fjdz" : mm.fjdz,
                                       @"fjgs" : mm.fjgs,
                                       @"fjmc" : mm.fjmc
                                       };
                [pgfjList addObject:dict];
        }
        
        if (item.xsfjID.length > 0) {
            NSDictionary *fkList = @{
                                     @"stList" : stListM,
                                     @"pgfjList" : pgfjList,
                                     @"xsfjID" : item.xsfjID,
                                     @"zyfjID" : item.zyfjID
                                     };
            [fkListM addObject:fkList];
        }
    }
    
    [SVProgressHUD show];
    WEAKSELF(self);
    [HWPhotographModel phototgraphTaskFeedbackWithFbdxID:self.taskModel.fbdxID jsID:[WDTeacher sharedUser].teacherID xsID:self.xsData.xsID zyID:self.taskModel.zyID fkList:fkListM handler:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"反馈成功", nil)];
            if (weakSelf.correctFinish) {
                weakSelf.correctFinish(weakSelf.student);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"反馈失败，请稍候再试", nil)];
        }
    }];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"题号", nil), NSLocalizedString(@"正确答案", nil),NSLocalizedString(@"学生答案", nil),NSLocalizedString(@"分值/得分", nil),NSLocalizedString(@"判题", nil)]];
    }
    return _dataSource;
}

- (void)keyboradShow:(NSNotification *)info {
    UIButton *btn = [UIButton new];
    btn.frame = [UIScreen mainScreen].bounds;
//    [self.view addSubview:btn];
    [[UIApplication sharedApplication].keyWindow addSubview:btn];
    self.tempBtn = btn;
    [btn addTarget:self action:@selector(keyboradHide:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboradHide:(UIButton *)sender {
    sender.hidden = true;
    sender.alpha = 0;
    [sender removeFromSuperview];
    sender = nil;
//    [self.view endEditing:true];
    [self.collectionView endEditing:true];
//    resignFirstResponder
//    [self.tempTextField resignFirstResponder];
}

@end

