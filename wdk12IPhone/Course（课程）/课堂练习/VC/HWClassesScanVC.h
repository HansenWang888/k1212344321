//
//  HWClassesScanVC.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesCaptureVC.h"

@interface HWClassesScanVC : HWClassesCaptureVC

+ (instancetype)classesScanWithBjID:(NSString *)bjID;
- (void)hideSubmitButton;
@end
