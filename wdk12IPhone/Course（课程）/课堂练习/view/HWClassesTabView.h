//
//  HWClassesTabView.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HWClassesTabViewDelegate <NSObject>

- (void)classesTabBackButtonClick;
- (void)classesTabSubmitButtonClickWithStudentList:(NSArray *)list;
- (void)classesTabResetButtonClick;

@end
@interface HWClassesTabView : UIView
@property (nonatomic, weak) id<HWClassesTabViewDelegate> delegate;
- (void)hideSubmitButton;
+ (instancetype)classesTabView;
@end
