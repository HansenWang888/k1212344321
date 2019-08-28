//
//  HWPhotoViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPhotographModel;

///  照片查看控制器
@interface HWPhotoViewController : UIViewController

@property (nonatomic, strong) HWPhotographModel *dataSource;

@property (nonatomic, assign) NSInteger index;

@end
