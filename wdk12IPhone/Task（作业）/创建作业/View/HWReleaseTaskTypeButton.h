//
//  HWReleaseTaskTypeButton.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWReleaseTaskTypeButton : UIButton

@property (nonatomic, strong) UILabel *titlelabel;
///  选中的中心view
@property (nonatomic, strong) UIView *selectCenterView;

@property (nonatomic, assign) BOOL isSel;

@end
