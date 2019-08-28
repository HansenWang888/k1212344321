//
//  SubscribeInfoController.h
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CANCLESUBSCRIBE_ATTENTION_NOTIFICATION @"cancle_subscribe_attention"
@interface SubscribeInfoController : UITableViewController

-(id)initWithSBID:(NSString*)sbid;

@end
