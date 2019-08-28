//
//  HWReleaseContentCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/14.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWReleaseContentCell.h"
#import "NotOnlineCollectionViewCell.h"
#import "ResourceVCViewController.h"
#import "WDAttachmentAlertView.h"
#import "HWAccessoryModel.h"
#import "WDHTTPManager.h"
#import "MediaOBJ.h"

@interface HWReleaseContentCell ()<UICollectionViewDelegate, UICollectionViewDataSource, WDAttachmentAlertDelegate, UIWebViewDelegate>

///  发布作业名称
@property (nonatomic, strong) UILabel *nameLabel;
///  内容label
@property (nonatomic, strong) UILabel *contentLabel;
///  内容textView
@property (nonatomic, strong) UIWebView *webView;
///  布局类
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  附件
@property (nonatomic, strong) UICollectionView *collectionView;
///  附件数据源
@property (nonatomic, strong) NSMutableArray<HWAccessoryModel *> *data;

@property (nonatomic, strong) WDAttachmentAlertView *alertView;
///  是否是作业内容
@property (nonatomic, assign) BOOL isTaskContent;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *centerView;

@end

@implementation HWReleaseContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.nameLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x2F9B8C alpha:1.0] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.nameTextField = [UITextField new];
    self.contentLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x2F9B8C alpha:1.0] font:[UIFont systemFontOfSize:14] alpha:1.0];
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[NotOnlineCollectionViewCell class] forCellWithReuseIdentifier:@"NotOnlineCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.layout.itemSize = CGSizeMake(83, 83);
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.webView = [[UIWebView alloc] init];
    NSString *path = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/webapp/app/jsp/index.html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    self.webView.scrollView.showsVerticalScrollIndicator = false;
    self.webView.scrollView.showsHorizontalScrollIndicator = false;
    
    self.topView = [UIView viewWithBackground:[UIColor hex:0xEFEFEF alpha:1.0] alpha:1.0];
    self.centerView = [UIView viewWithBackground:[UIColor hex:0xEFEFEF alpha:1.0] alpha:1.0];
    
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.nameTextField];
    [self.contentView addSubview:self.centerView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.webView];
    [self.contentView addSubview:self.collectionView];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"作业名称", nil)];
    self.contentLabel.text = [NSString stringWithFormat:@"%@:  ", NSLocalizedString(@"作业内容", nil)];
    
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.nameTextField.layer.borderWidth = 1.0;
    self.webView.layer.borderColor = [UIColor grayColor].CGColor;
    self.webView.layer.borderWidth = 1.0;
}

- (void)initAutoLayout {
    [self.topView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth], 10) offset:CGPointMake(0, 0)];
    [self.nameLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.topView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.nameTextField zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.nameLabel size:CGSizeMake([UIScreen wd_screenWidth] - 20, 34) offset:CGPointMake(0, 10)];
    [self.centerView zk_AlignVertical:ZK_AlignTypeBottomCenter referView:self.nameTextField size:CGSizeMake([UIScreen wd_screenWidth], 10) offset:CGPointMake(0, 10)];
    [self.contentLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.centerView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.webView zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.contentLabel size:CGSizeMake([UIScreen wd_screenWidth] - 20, 400) offset:CGPointMake(0, 10)];
    [self.collectionView zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.webView size:CGSizeMake([UIScreen wd_screenWidth] - 20, 90) offset:CGPointMake(0, 10)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"wd:"]) { // 打开相机
        self.isTaskContent = true;
        [self performSelector:@selector(selectPhotoFrom) withObject:self afterDelay:0.1];
    }
    return true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"init()"];
    [webView stringByEvaluatingJavaScriptFromString:@"setCurrentType('2')"];
    if ([System_Language isEqualToString:@"ch"]) {
        [webView stringByEvaluatingJavaScriptFromString:@"setLanguage('ch')"];
    }else {
        [webView stringByEvaluatingJavaScriptFromString:@"setLanguage('en')"];
    }
}

///  选择照片来源
- (void)selectPhotoFrom {
    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"上传附件", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"拍照", nil),NSLocalizedString(@"相册", nil),NSLocalizedString(@"手写", nil), nil];
    self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self.superViewController aler:alert];
    self.alertView.attachmentDelegate = self;
    self.alertView.isWrite = YES;
    [self.alertView show];
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
        self.isTaskContent = false;
        self.alertView = [WDAttachmentAlertView attachmentAlertViewWithVC:self.superViewController];
        self.alertView.attachmentDelegate = self;
        [self.alertView show];
        return ;
    }
    HWAccessoryModel *model = self.data[indexPath.row - 1];
    ResourceVCViewController* vc = [[ResourceVCViewController alloc] initWithPath:model.fjdz ConverPath:model.fjzmdz Type:model.fjgs Name:model.fjmc];
    [self.superViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
}

///  删除附件数据源方法
- (void)deleteAttachmentDataSource:(UIButton *)sender {
    
    NSIndexPath *index = [self.collectionView indexPathForCell:(UICollectionViewCell *)sender.superview.superview];
    [self.data removeObjectAtIndex:index.row - 1];
    [self.collectionView deleteItemsAtIndexPaths:@[index]];
}

//MARK:WDAttachmentAlertDelegate
- (void)imageAfterDrawing:(UIImage *)image {
    if (image) {
        [self uploadAttachmentWithData:UIImageJPEGRepresentation(image, 0.2) type:@"png"];
    }
}

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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在上传", nil)];
    
    MediaOBJ *obj = [MediaOBJ new];
    obj.mediaType = type;
    obj.mediaData = data;
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger] uploadWithAdjunctFileWithData:@[obj] progressBlock:nil finished:^(NSDictionary *data) {
        [SVProgressHUD dismiss];
        if (weakSelf.isTaskContent) {
            NSArray *array = data[@"msgObj"];
            NSDictionary *di = array.firstObject;
            NSString *str = [NSString stringWithFormat:@"appendAttachment('%@/%@')", FILE_SEVER_DOWNLOAD_URL, di[@"fileId"]];
            [self.webView stringByEvaluatingJavaScriptFromString:str];
        } else {
            HWAccessoryModel *model = [HWAccessoryModel new];
            NSDictionary *dict = [data[@"msgObj"] firstObject];
            model.fjdx = dict[@"fileSize"];
            model.fjmc = dict[@"fileName"];
            model.fjdz = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL, dict[@"fileId"]];
            model.fjdzNotBaseUrl = [NSString stringWithFormat:@"%@", dict[@"fileId"]];
            model.fjgs = dict[@"fileExtName"];
            [self.data insertObject:model atIndex:0];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
        }
    }];
}

//  发布作业方法
- (NSDictionary *)releaseTaskAction {
    NSString *taskContent = [self.webView stringByEvaluatingJavaScriptFromString:@"getRichText()"];
    NSString *str = [taskContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [str componentsSeparatedByString:@"_wd_"];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"zymc"] = self.nameTextField.text;
    dictM[@"zynr"] = array[0];
    dictM[@"wznr"] = array[1];
    
    NSMutableArray *tpnr = [NSMutableArray array];
    NSArray *tpList = [array[2] componentsSeparatedByString:@","];
    for (NSString *str in tpList) {
        [tpnr addObject:str];
    }
    if (tpnr.count > 0) {
        NSData *tpnrData = [NSJSONSerialization dataWithJSONObject:tpnr options:0 error:nil];
        dictM[@"tpnr"] = [[NSString alloc] initWithData:tpnrData encoding:NSUTF8StringEncoding];
    } else {
        dictM[@"tpnr"] = @"";
    }
    
    NSMutableArray *fjData = [NSMutableArray array];
    for (HWAccessoryModel *item in self.data) {
        NSDictionary *fj = @{@"fjgs" : item.fjgs,
                             @"fjmc" : item.fjmc,
                             @"fjdz" : item.fjdzNotBaseUrl,
                             @"fjdx" : item.fjdx};
        [fjData addObject:fj];
    }
    if (fjData.count > 0) {
        NSData *fjListData = [NSJSONSerialization dataWithJSONObject:fjData options:0 error:nil];
        dictM[@"fjList"] = [[NSString alloc] initWithData:fjListData encoding:NSUTF8StringEncoding];
    } else {
        dictM[@"fjList"] = @"";
    }
    return dictM;
}

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}


@end
