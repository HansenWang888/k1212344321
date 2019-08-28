//
//  AppDelegate.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "WDLoginModule.h"
#import "WDSQLManager.h"
#import <AFNetworkActivityIndicatorManager.h>
#import "mySettingViewController.h"
#import "WDHTTPManager.h"
#import "WDAdvertisementVC.h"

@interface AppDelegate ()

@end

#define appID @"1196168019"
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[WDLogManager shareManager] setAppID:appID];
    [WDLogManager initializeAppLog];
    //设置全局网络缓存
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:1024 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache];
    
    //打开网络小菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    //监听登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeController:) name:loginNotifacation object:nil];
    
    //监听登出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowLoginController) name:logoutNotifacation object:nil];   
    [self showWebView];
    return YES;

}
- (void)loadVC {
    [self autoLogin];
    [self inspectUpdate];
}
- (void)showWebView {
    //如果没登陆过location用6个0
    NSString *location = nil;
    location = [[NSUserDefaults standardUserDefaults] objectForKey:Location_Key];
    if (location.length == 0) {
        location = @"000000";
    }
    NSString *url = [NSString stringWithFormat:@"%@/information/getNewNotice?appID=%@&location=%@&version=132",SERVER_ADDRESS_URL,appID,location];
    WEAKSELF(self);
    WDAdvertisementVC *main = [WDAdvertisementVC advertisementWithURL:url closeBlock:^{
        [weakSelf loadVC];
    }];
    [self.window setRootViewController:main];
    [self.window makeKeyAndVisible];
}
//自动验证登录
- (void)autoLogin{
    [WDLoginModule shareInstance];
    [self ShowLoginController];
}

-(void)loginChangeController:(NSNotification*) notify{
    [self ShowMainController];
}

-(void)ShowMainController{
    MainViewController *main = [[MainViewController alloc] init];
    self.window.rootViewController = main;
    [self.window makeKeyAndVisible];
}
-(void)ShowLoginController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginViewController *login = [story instantiateViewControllerWithIdentifier:@"Login"];
    self.window.rootViewController = login;
    [self.window makeKeyAndVisible];
}
//检测更新
- (void)inspectUpdate {
    //获取App Store信息
    NSString *appURL = WDFormatString(@"http://itunes.apple.com/lookup?id=", appID);
    __block NSString *version = nil;
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:nil urlString:appURL finished:^(NSDictionary *dict) {
        if ([dict[@"resultCount"] integerValue] == 1) {
            NSLog(@"%@",dict);
            //获取本地版本号
            version = dict[@"results"][0][@"version"];
            NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            localVersion = [localVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (version.integerValue > localVersion.integerValue) {
                //提示更新
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"检测到有新版本，请确定是否更新？", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles: NSLocalizedString(@"确定", nil), nil];
                [alert show];
            }
        }
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //跳转AppStore下载
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@",appID]]];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
   
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    
}

@end
