//
//  WDAttachmentAlertView.m
//  wdk12pad
//
//  Created by 老船长 on 16/7/2.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "WDAttachmentAlertView.h"
#import "LSYAlbumCatalog.h"
#import "RecordViewController.h"
#import "WDDrawingBoardViewController.h"

@interface WDAttachmentAlertView ()<UIAlertViewDelegate,LSYAlbumCatalogDelegate,RecordViewVCDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, strong) UIImagePickerController *pickerController;

@end
@implementation WDAttachmentAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)attachmentAlertViewWithVC:(UIViewController *)vc {
    WDAttachmentAlertView *alert = [[WDAttachmentAlertView alloc] initWithTitle:NSLocalizedString(@"上传附件", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"相册", nil), NSLocalizedString(@"录音", nil),NSLocalizedString(@"摄像", nil), nil];
    alert.delegate = alert;
    alert.currentVC = vc;
    return alert;
}

+ (instancetype)attachmentAlertViewWithVC:(UIViewController *)vc aler:(WDAttachmentAlertView *)aler {
    WDAttachmentAlertView *alert = aler;
    alert.delegate = alert;
    alert.currentVC = vc;
    return alert;
}

//MARK:alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        self.pickerController.mediaTypes = @[@"public.image"];
        [self shootPiicturePrVideo];
    } else if (buttonIndex == 2){
        LSYAlbumCatalog *albumCatalog = [[LSYAlbumCatalog alloc] init];
        albumCatalog.delegate = self;
        albumCatalog.maximumNumberOfSelectionMedia = 5;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumCatalog];
        [self.currentVC presentViewController:nav animated:YES completion:nil];
    } else if (buttonIndex == 3){
        
        if (_isWrite) {
            NSLog(@"手写");
            WDDrawingBoardViewController *drawingVC = [[WDDrawingBoardViewController alloc] init];
            [drawingVC setBackImage:[UIImage imageNamed:@"huaban_3"] finishedImage:^(UIImage *image) {
                if (image) {
                    [_attachmentDelegate imageAfterDrawing:image];
                }
            }];
            [self.currentVC presentViewController:drawingVC animated:YES completion:nil];
            return;
        }
        
        RecordViewController *recordVC = [[UIStoryboard storyboardWithName:@"RecordVC" bundle:nil] instantiateViewControllerWithIdentifier:@"recordVC"];
        recordVC.recordDelegate = self;
        [self.currentVC presentViewController:recordVC animated:YES completion:nil];
    } else if (buttonIndex == 4){
        self.pickerController.mediaTypes = @[@"public.movie"];
        [self shootPiicturePrVideo];
    }
}

//MARK:拍照功能
#pragma  mark- 拍照模块
-(void)shootPiicturePrVideo{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if(mediatypes.count > 0){
        //IOS8多了一个样式UIModalPresentationOverCurrentContext，IOS8中presentViewController时请将控制器的modalPresentationStyle设置为UIModalPresentationOverCurrentContext
        self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:1];
        for (NSString* mediaType in self.pickerController.mediaTypes) {
            if ([mediaType isEqualToString:@"public.image"]) {
                [arrayM removeAllObjects];
                [arrayM addObject:mediaType];
                _pickerController.mediaTypes = arrayM;
                [self.currentVC presentViewController:_pickerController animated:YES completion:nil];
            } else if ([mediaType isEqualToString:@"public.movie"]){
                [arrayM removeAllObjects];
                [arrayM addObject:mediaType];
                _pickerController.mediaTypes = @[@"public.movie"];
                [self.currentVC presentViewController:_pickerController animated:YES completion:nil];
            }
        }
    } else{
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"错误信息!", nil) message:NSLocalizedString(@"当前设备不支持拍摄功能", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"知道了", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertControl addAction:action];
        [self.currentVC presentViewController:alertControl animated:YES completion:nil];
    }
}
//MARK:ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType =[info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqual:(NSString *) kUTTypeImage])
    {
        UIImage *chosenImage =[info objectForKey:UIImagePickerControllerEditedImage];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSLocalDomainMask, YES);
//        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"pic_%d.png", myI]];   // 保存文件的名称
       // NSData *data = UIImageJPEGRepresentation(chosenImage, 0.1);
        [self.attachmentDelegate attachmentWithPhotos:@[chosenImage]];
//        [data writeToFile:filePath atomically:YES];
        
    } else if([mediaType isEqual:(NSString *) kUTTypeMovie]) {
        //获取视频文件的url
        NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [self.attachmentDelegate attachmentWithVideoURL:mediaURL];
//        NSData *data = [NSData dataWithContentsOfURL:mediaURL];
      
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//MARK:from Album photoes pictures
-(void)AlbumDidFinishPick:(NSArray *)assets {
    NSMutableArray *arrayM = @[].mutableCopy;
    for (ALAsset *asset in assets) {
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
        if ([assetType isEqual:ALAssetTypePhoto]) {
            UIImage * img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            [arrayM addObject:img];
           // NSData *data = UIImageJPEGRepresentation(img, 0.1);//压缩图片
            
        } else if ([assetType isEqualToString:ALAssetTypeVideo]) {
//            ALAssetRepresentation * rep = [asset defaultRepresentation];
//            NSString *videoStr = [asset valueForProperty:ALAssetPropertyAssetURL];
        }
    }

    [self.attachmentDelegate attachmentWithPhotos:arrayM.copy];
}

// albumCancleSelected
- (void)albumCancleSelected {
    [self.currentVC dismissViewControllerAnimated:true completion:nil];
}

//MARK:recordDelegate
- (void)recordCompeletedWithRecordURL:(NSString *)recordURL recordData:(NSData *)data {
    [self.attachmentDelegate attachmentWithRecordURL:[NSURL URLWithString:recordURL]];
}
- (UIImagePickerController *)pickerController {
    
    if (!_pickerController) {
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.videoMaximumDuration = 10 * 60;//set  shotting's long time
        _pickerController.delegate = self;
        _pickerController.allowsEditing = YES;
    }
    return _pickerController;
}
@end
