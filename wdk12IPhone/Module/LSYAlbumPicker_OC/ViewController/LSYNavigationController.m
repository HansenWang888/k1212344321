//
//  LSYNavigationController.m
//  AlbumPicker
//
//  Created by okwei on 15/7/24.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

#import "LSYNavigationController.h"
#import "LSYAlbumPicker.h"
#import "LSYAlbumCatalog.h"
@interface LSYNavigationController ()

@end

@implementation LSYNavigationController
-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
}
@end
