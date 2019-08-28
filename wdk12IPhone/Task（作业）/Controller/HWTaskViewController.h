//
//  HWTaskViewController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubjectListRequest;

///  作业控制器
@interface HWTaskViewController : UIViewController

///  科目数据
@property (nonatomic, strong) NSString *subjectID;

- (void)loadDataWithKMid:(NSString *)kmid;

@end
