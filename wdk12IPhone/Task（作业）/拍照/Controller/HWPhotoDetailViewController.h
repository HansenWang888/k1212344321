//
//  HWPhotoDetailViewController.h
//  wdk12IPhone
//
//  Created by 官强 on 2017/7/11.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPhotographModel;
@interface HWPhotoDetailViewController : UIViewController

@property (nonatomic, strong) HWPhotographModel *model;

@property (nonatomic, copy) void (^saveBack)(HWPhotographModel *);

@end
