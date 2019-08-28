//
//  WDDelineateVC.h
//  公共框架管理
//
//  Created by 老船长 on 2017/6/16.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDelineateVC : UIViewController
///横屏编辑
+ (instancetype)delineateHorizonVCWithImage:(UIImage *)image;
///竖屏编辑
+ (instancetype)delineateVeticalVCWithImage:(UIImage *)image;
///白板横屏编辑
+ (instancetype)delineateHorizonBlankVC;
///白板竖屏编辑
+ (instancetype)delineateVerticalBlankVC;

///回调后会自动退出
@property (nonatomic, copy) void(^finishedBlock)(UIImage *image,WDDelineateVC *vc);

@end
