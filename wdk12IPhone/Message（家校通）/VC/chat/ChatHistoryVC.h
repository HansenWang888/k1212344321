//
//  ChatHistoryVC.h
//  wdk12pad-HD-T
//
//  Created by macapp on 16/4/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionEntity;
@interface ChatHistoryVC : UITableViewController


-(id)initWithSubscribeID:(NSString*)sbid;
//-(id)initWithSession:(SessionEntity*)sentity;
@end
