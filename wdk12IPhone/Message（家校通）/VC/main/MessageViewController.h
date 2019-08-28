//
//  MessageViewController.h
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "anchorView.h"
#import "ContactTableView.h"
#import "SessionTableView.h"
@interface MessageViewController : UIViewController<AnchorViewDelegate,ContactTableViewCellTouchedDelegate,SessionTableViewDelegta>

@end
