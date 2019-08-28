//
//  MoviePlayerControllerViewController.h
//  WdEduApp-i
//
//  Created by 布依男孩 on 15/9/9.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviePlayerController : UIViewController
- (void)stepUIAndURL:(NSURL *)url;
@property (nonatomic, copy) NSString *titleAsset;

@end
