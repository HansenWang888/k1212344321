//
//  PresentedDelegaet.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/24.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PresentedDelegate : NSObject <UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>
@property (nonatomic, assign) CGRect rect;

- (void)dismissDuumyView;
@end
