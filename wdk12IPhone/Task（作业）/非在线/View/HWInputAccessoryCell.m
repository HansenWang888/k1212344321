//
//  HWInputAccessoryCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWInputAccessoryCell.h"
#import "NotOnlineCollectionViewCell.h"
#import "ResourceVCViewController.h"
#import "WDAttachmentAlertView.h"
#import "HWAccessoryModel.h"
#import "WDHTTPManager.h"
#import "MediaOBJ.h"
#import "WDShowImageController.h"

@interface HWInputAccessoryCell ()<UICollectionViewDelegate, UICollectionViewDataSource, WDAttachmentAlertDelegate>

///  布局类
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  附件
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) WDAttachmentAlertView *alertView;

@end

@implementation HWInputAccessoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[NotOnlineCollectionViewCell class] forCellWithReuseIdentifier:@"NotOnlineCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.layout.itemSize = CGSizeMake(70, 70);
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.contentView addSubview:self.collectionView];
}

- (void)initAutoLayout {
    [self.collectionView zk_Fill:self.contentView insets:UIEdgeInsetsZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sessionplus"]];
        [cell.contentView addSubview:imageView];
        [imageView zk_AlignInner:ZK_AlignTypeCenterCenter referView:cell.contentView size:CGSizeZero offset:CGPointZero];
        cell.contentView.layer.borderColor = [UIColor grayColor].CGColor;
        cell.contentView.layer.borderWidth = 1.0;
        return cell;
    }
    NotOnlineCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"NotOnlineCollectionViewCell" forIndexPath:indexPath];
    cell.delButton.alpha = 1.0;
    [cell.delButton addTarget:self action:@selector(deleteAttachmentDataSource:) forControlEvents:UIControlEventTouchUpInside];
    cell.data = self.data[indexPath.row - 1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // 调取相机接口
        self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self.superViewController];
        self.alertView.attachmentDelegate = self;
        [self.alertView show];
        return ;
    }
    HWAccessoryModel *data = self.data[indexPath.row - 1];
    
    if ([WDShowImageController isImage:data.fjgs]) {
        [self presentToPhotoBroswerVC:data.fjdz];
    }else {
        ResourceVCViewController* vc = [[ResourceVCViewController alloc] initWithPath:data.fjdz ConverPath:data.fjdz Type:data.fjgs Name:data.fjmc];
        [self.superViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
    }
    
    
}
- (void)presentToPhotoBroswerVC:(NSString *)imageUrl {
    if (![imageUrl hasPrefix:@"http"]) {
        imageUrl =  [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL,imageUrl];
    }
    UIViewController *vc = [WDShowImageController initImageVC:@"" imageUrlArray:@[imageUrl] index:0];
    [self.superViewController presentViewController:vc animated:YES completion:nil];
}
///  删除附件数据源方法
- (void)deleteAttachmentDataSource:(UIButton *)sender {
    
    NSIndexPath *index = [self.collectionView indexPathForCell:(UICollectionViewCell *)sender.superview.superview];
    [self.data removeObjectAtIndex:index.row - 1];
    [self.collectionView deleteItemsAtIndexPaths:@[index]];
}

- (void)addImage:(UIImage *)image {

    [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 1) type:@"png"];
}

//MARK:WDAttachmentAlertDelegate
- (void)attachmentWithRecordURL:(NSURL *)url {
    //上传。。。
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp3"];
}

- (void)attachmentWithPhotos:(NSArray<UIImage *> *)imgs {
    //上传。。。
    for (UIImage *image in imgs) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
    [self.superViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)attachmentWithVideoURL:(NSURL *)url {
    //上传。。。
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self uploadAttachmentWithData:data type:@"mp4"];
}

- (void)uploadAttachmentWithData:(NSData *)data type:(NSString *)type {
    
    MediaOBJ *obj = [MediaOBJ new];
    obj.mediaType = type;
    obj.mediaData = data;
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger] uploadWithAdjunctFileWithData:@[obj] progressBlock:nil finished:^(NSDictionary *data) {
        if (data) {
            HWAccessoryModel *model = [HWAccessoryModel new];
            NSDictionary *dict = [data[@"msgObj"] firstObject];
            model.fjdx = dict[@"fileSize"];
            model.fjmc = dict[@"fileName"];
            model.fjdz = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL, dict[@"fileId"]];
            model.fjdzNotBaseUrl = [NSString stringWithFormat:@"%@", dict[@"fileId"]];
            model.fjgs = dict[@"fileExtName"];
            [weakSelf.data insertObject:model atIndex:0];
            [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
        }
    }];
}

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

@end
