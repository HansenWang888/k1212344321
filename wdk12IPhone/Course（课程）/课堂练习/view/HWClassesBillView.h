//
//  HWClassesBillView.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWClassesBillView : UIView

- (void)showDataWithStudentList:(NSArray *)list;//显示未扫描
- (NSArray *)showScanedStudentList:(NSArray *)array;//显示已扫描
- (void)onlyShowScanedTable;
- (void)resetData;
- (NSArray *)getScanedStudents;
+ (instancetype)classesBillView;
@end
