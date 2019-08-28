//
//  IMChatPhotoView.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "IMChatPhotoView.h"
#import "ViewSetUniversal.h"
#import "IMPhotoModel.h"
#import "LSYAlbum.h"
@interface IMPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet  UIImageView *imgView;
@property (nonatomic, strong) IBOutlet  UIButton *seletedBtn;
@property (nonatomic, strong) IMPhotoModel *model;
@property (nonatomic, copy) void(^btnClick)(IMPhotoCollectionCell *cell);
@end

@implementation IMPhotoCollectionCell

- (void)awakeFromNib {
    [self.seletedBtn setTitle:@"\U0000e652" forState:UIControlStateNormal];
    [self.seletedBtn setTitle:@"\U0000e651" forState:UIControlStateSelected];
//    self.imgView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.imgView.layer.borderWidth = 1.0;
}
- (IBAction)seletedBtnClick {
    self.seletedBtn.selected = !self.seletedBtn.selected;
    self.btnClick(self);
}
-  (void)setModel:(IMPhotoModel *)model {
    _model = model;
    self.imgView.image = [UIImage imageWithCGImage:model.asset.aspectRatioThumbnail];
    self.seletedBtn.selected = model.isSelect;
}
@end

@interface IMChatPhotoView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, copy) NSArray<IMPhotoModel *> *photos;

@property (assign, nonatomic) NSInteger selectedCount;

@end

@implementation IMChatPhotoView


- (IBAction)cameraBtnClick {
    if(_delegate){
        [_delegate showCamera:self.cameraBtn];
    }

}

- (IBAction)photosBtnClick {
    if(_delegate){
        if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
            [_delegate showAlbum:self.photoBtn];
        } else {
            [self alertViewCamera];
        }
    }
}

- (IBAction)sendBtnClick:(id)sender {
    NSMutableArray *arrayM = @[].mutableCopy;
    for (IMPhotoModel *model in self.photos) {
        if (model.isSelect) {
            [arrayM addObject:model];
        }
    }
    if (arrayM.count == 0) {
        [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"请选择图片", nil)];
        return;
    }
    if(_delegate){
        [_delegate disSelectedPhotos:arrayM];
//        //清空所有选择
//        for (IMPhotoModel *model in arrayM) {
//            model.isSelect = NO;
//        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [ViewSetUniversal setView:self.photoBtn borderWitdth:1 borderColor:[UIColor grayColor]];
    [ViewSetUniversal setView:self.sendBtn borderWitdth:1 borderColor:[UIColor grayColor]];
    [ViewSetUniversal setView:self.photoBtn cornerRadius:3];
    [ViewSetUniversal setView:self.sendBtn cornerRadius:3];
    [ViewSetUniversal setView:self.cameraBtn borderWitdth:1 borderColor:[UIColor grayColor]];
    [ViewSetUniversal setView:self.cameraBtn cornerRadius:3];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.collectionViewLayout = flow;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"IMPhotoCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
//    [self.cameraBtn setTitle:@"\U0000e642" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    [[LSYAlbum sharedAlbum] photosWithFinished:^(NSArray<IMPhotoModel *> *photos) {
        if (photos) {
            weakSelf.photos = photos;
            weakSelf.countLabel.text = [NSString stringWithFormat:@"0/%tu",photos.count];
            [weakSelf.collectionView reloadData];
        } else {
            weakSelf.countLabel.text = [NSString stringWithFormat:@"0/%tu",photos.count];
            [weakSelf alertViewCamera];
        }
    }];
    self.selectedCount = 0;
    [self.photoBtn setTitle:IMLocalizedString(@"相册", nil) forState:UIControlStateNormal];
    [self.sendBtn setTitle:IMLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [self.cameraBtn setTitle:IMLocalizedString(@"拍照", nil) forState:UIControlStateNormal];

    
}
- (void)alertViewCamera {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMLocalizedString(@"访问相册失败", nil) message:IMLocalizedString(@"您可以在系统中的设置中的左边目录找到'12Study',打开允许相册访问开关!", nil) delegate:self cancelButtonTitle:IMLocalizedString(@"知道了", nil) otherButtonTitles:IMLocalizedString(@"去设置", nil), nil];
    [alert show];
}
//MARK:alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    if (buttonIndex == 1) {
        //跳转设置应用
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=General"]]){
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
        } else {
            [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"打开失败", nil)];
        }
    }
}
- (void)photoChoiceWithCell:(IMPhotoCollectionCell *)cell {
    IMPhotoModel *model = cell.model;
    model.isSelect = !model.isSelect;
    cell.seletedBtn.selected = model.isSelect;
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%tu",model.isSelect ? ++self.selectedCount : -- self.selectedCount,self.photos.count];
}
+ (instancetype)chatPhotoView {
    return [[[NSBundle mainBundle] loadNibNamed:@"IMChatPhotoView" owner:nil options:nil] lastObject];
}
-  (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.photos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IMPhotoModel *model = self.photos[indexPath.row];
    IMPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    cell.model = model;
    WEAKSELF(self);
    cell.btnClick = ^(IMPhotoCollectionCell *clickCell) {
        [weakSelf photoChoiceWithCell:clickCell];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IMPhotoCollectionCell *cell = (IMPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self photoChoiceWithCell:cell];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    IMPhotoModel *photo = self.photos[indexPath.row];
//    CGFloat width = collectionView.bounds.size.height / photo.image.size.height * photo.image.size.width;
    
    return CGSizeMake(200, collectionView.bounds.size.height);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 3, 0, 3);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}
- (void)dealloc {
    NSLog(@"photoView--888");
}
@end
