//
//  RevampGender.h
//  wdk12IPhone
//
//  Created by cindy on 15/11/18.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RevampGenderViewController : UIViewController

@property (nonatomic,copy) NSString * genderType;

@property (nonatomic, copy) void(^modifySex)(void);

@end
