//
//  WDAdvertisementVC.h
//  wdk12IPhone
//
//  Created by 老船长 on 2017/3/23.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDAdvertisementVC : UIViewController

+ (instancetype)advertisementWithURL:(NSString *)url closeBlock:(void(^)())closeBlock;
@end
