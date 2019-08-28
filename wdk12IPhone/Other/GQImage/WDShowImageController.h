//
//  WDShowImageController.h
//  是生死
//
//  Created by 官强 on 2017/8/17.
//  Copyright © 2017年 guanqiang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface WDShowImageController : UIViewController

+ (UIViewController *)initImageVC:(NSString *)title imageUrlArray:(NSArray *)imageArr index:(NSInteger)index;

+ (UIViewController *)initLocalImageVC:(NSString *)title imageUrlArray:(NSArray *)imageArr index:(NSInteger)index;


+ (BOOL)isImage:(NSString *)string;

@end
