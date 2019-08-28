//
//  WDSchedulerView.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDSchedulerView : UIView

@property (nonatomic, copy) void (^clickedBlock)(NSDictionary *dict);




+ (CGFloat)getHeight;

@end
