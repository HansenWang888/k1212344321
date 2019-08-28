//
//  MainViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "MainViewController.h"
#import "NavigationViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addController];
    
    self.tabBar.selectedImageTintColor = [UIColor colorWithRed:57/255.0 green:235/255.0 blue:207/255.0 alpha:1.0];
    //修改tabBarItem的字体颜色
    for (UITabBarItem *tabBarItem in self.tabBar.subviews) {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:57/255.0 green:235/255.0 blue:207/255.0 alpha:1.0],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
}
//添加子控制器
- (void)addController{
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"ControllerJSON.json" ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:str];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 0; i< array.count; ++i) {
        NSDictionary *dict = array[i];
        [self creatController:dict[@"ctlName"] title:NSLocalizedString(dict[@"titleName"], nil) imageName:dict[@"imageName"]];
    }
}
///  创建控制器
///  @param controllerName 控制器类名
///  @param title          标题
- (void)creatController:(NSString *)controllerName title:(NSString *)title imageName:(NSString *)imgName{
    
    Class cls = NSClassFromString(controllerName);
    //将字符串转成类对象
    UIViewController *vc = [[cls alloc] init];
    vc.title = title;
    [vc.tabBarItem setImage:[UIImage imageNamed:imgName]];
    NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}
@end
