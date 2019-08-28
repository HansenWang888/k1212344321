//
//  HyperLinkVC.h
//  wdk12pad
//
//  Created by macapp on 16/2/22.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HyperLinkVC : UIViewController
-(id)initWithHyperLink:(NSString*)href AndTitle:(NSString*)title;
-(id)initWithHtmlStr:(NSString*)htmlstr;
@end
