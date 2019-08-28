//
//  ResourceVCViewController.h
//  wdk12pad
//
//  Created by macapp on 15/12/29.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceVCViewController : UIViewController

@property UIProgressView* progressView;
@property UIWebView*      webview;
-(id)initWithPath:(NSString*)path ConverPath:(NSString*)converpath Type:(NSString*)type Name:(NSString*)name;

-(void)createWebView;
-(void)createProgressView;

@end
