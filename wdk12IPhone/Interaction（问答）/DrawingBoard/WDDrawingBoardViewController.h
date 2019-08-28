//
//  WDDrawingBoardViewController.h
//  HBDrawViewDemo
//
//  Created by guanqiang on 16/12/5.
//  Copyright © 2016年 wdy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDrawingBoardViewController : UIViewController

- (void)setBackImage:(UIImage *)backImage finishedImage:(void(^)(UIImage *image))finishedBlock;

@end
