//
//  RevampInfoViewController.h
//  Wd_Setting
//
//  Created by cindy on 15/10/15.
//  Copyright © 2015年 wd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RevampInfoViewController : UIViewController

@property(nonatomic,strong) NSString * justTitle;

@property (nonatomic, copy) void(^modifyInfo)(void);

@end
