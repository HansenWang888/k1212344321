//
//  WDDrawingBoardViewController.m
//  HBDrawViewDemo
//
//  Created by guanqiang on 16/12/5.
//  Copyright © 2016年 wdy. All rights reserved.
//

#import "WDDrawingBoardViewController.h"
#import "ZYQAssetPickerController.h"
#import "UIView+WHB.h"
#import "HBDrawView.h"

@interface WDDrawingBoardViewController ()<ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HBDrawViewDelegate>


@property (nonatomic, strong) HBDrawView *drawView;

@property (nonatomic, strong) UIImage *backgroudImage;

@property (nonatomic, copy) void (^finishedImageBlock)(UIImage *);

@end

@implementation WDDrawingBoardViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.drawView];
    [self addSettingBtn];
    if (self.backgroudImage) {
        [self.drawView setDrawBoardImage:self.backgroudImage];
    }else {
        [self.drawView setDrawBoardImage:[UIImage imageNamed:@"default_back_image.jpg"]];
    }

}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self drawingSettings:nil];
}
- (IBAction)drawSetting:(id)sender {
    
    [self.drawView showSettingBoard];
    
}

- (void)drawingSettings:(UIButton *)sender {
    [self.drawView showSettingBoard];
}

- (void)setBackImage:(UIImage *)backImage finishedImage:(void (^)(UIImage *))finishedBlock {
    
    if (backImage) {
        self.backgroudImage = backImage;
    }
    if (finishedBlock) {
        self.finishedImageBlock = finishedBlock;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSLog(@"width == %f,height == %f",image.size.width,image.size.height);
    
    [self.drawView setDrawBoardImage:image];
    
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.drawView showSettingBoard];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.drawView showSettingBoard];
    }];
}
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    NSMutableArray *marray = [NSMutableArray array];
    
    for(int i=0;i<assets.count;i++){
        
        ALAsset *asset = assets[i];
        
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        [marray addObject:image];
        
    }
    
    [self.drawView setDrawBoardImage:[marray firstObject]];
}

#pragma mark - HBDrawViewDelegate
- (void)drawView:(HBDrawView *)drawView action:(actionOpen)action
{
    switch (action) {
        case actionOpenAlbum:
        {
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc]init];
            picker.maximumNumberOfSelection = 1;
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.showEmptyGroups = NO;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
            
            break;
        case actionOpenCamera:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIImagePickerController *pickVc = [[UIImagePickerController alloc] init];
                
                pickVc.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickVc.delegate = self;
                [self presentViewController:pickVc animated:YES completion:nil];
                
            }else{
                
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示" , nil) message:NSLocalizedString(@"你没有摄像头", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
                [alter show];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)getFinishedImage:(UIImage *)image {
    
    if (image && self.finishedImageBlock) {
       self.finishedImageBlock(image);
       [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addSettingBtn {
    UIButton *settingBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    settingBtn.frame = CGRectMake(self.view.frame.size.width - 80, 150, 50, 50);
    [settingBtn setTitle:NSLocalizedString(@"设置", nil) forState:(UIControlStateNormal)];
    [settingBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [settingBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [settingBtn setBackgroundColor:[UIColor whiteColor]];
    settingBtn.layer.masksToBounds = YES;
    settingBtn.layer.borderWidth = 1.0f;
    settingBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    settingBtn.layer.cornerRadius = 25.0f;
    [settingBtn addTarget:self action:@selector(drawingSettings:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    
    [settingBtn addGestureRecognizer:panGes];
    [self.view addSubview:settingBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backBtn.frame = CGRectMake(20, 30, 30, 30);
    [backBtn setBackgroundColor:[UIColor blackColor]];
    [backBtn setImage:[UIImage imageNamed:@"drawing_back"] forState:(UIControlStateNormal)];
    backBtn.layer.masksToBounds = YES;
    backBtn.layer.cornerRadius = 15.0f;
    [backBtn addTarget:self action:@selector(backDismiss:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:backBtn];
}

- (void)backDismiss:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)panGestureHandle:(UIPanGestureRecognizer *)sender {
//    //视图前置操作
    [sender.view.superview bringSubviewToFront:sender.view];
    //拖拽
    CGPoint center = sender.view.center;
    CGFloat cornerRadius = sender.view.frame.size.width / 2;
    CGPoint translation = [sender translationInView:self.view];
    //NSLog(@"%@", NSStringFromCGPoint(translation));
    sender.view.center = CGPointMake(center.x + translation.x,center.y +translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
    //动画效果
    if (sender.state == UIGestureRecognizerStateEnded) {
        //计算速度向量的长度，当他小于200时，滑行会很短
        CGPoint velocity = [sender velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        //基于速度和速度因素计算一个终点
        float slideFactor = 0.1 * slideMult;
//        CGPoint finalPoint = CGPointMake(center.x + (velocity.x * slideFactor),center.y + (velocity.y * slideFactor));
        
        CGPoint finalPoint = CGPointMake(center.x,center.y);

        
        //限制最小［cornerRadius］和最大边界值［    self.view.bounds.size.width - cornerRadius］，以免拖动出屏幕界限
        finalPoint.x = MIN(MAX(finalPoint.x, cornerRadius),self.view.bounds.size.width - cornerRadius);
        finalPoint.y = MIN(MAX(finalPoint.y, cornerRadius),self.view.bounds.size.height - cornerRadius);
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             sender.view.center = finalPoint;
                         }
                         completion:nil];
        
    }
}

- (HBDrawView *)drawView
{
    if (!_drawView) {
        _drawView = [[HBDrawView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _drawView.delegate = self;
    }
    return _drawView;
}

@end
