//
//  MGPSession.h
//  MobileGateWay
//
//  Created by macapp on 17/3/17.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPSerializeProtocol.h"
@interface MGPSession : NSObject
+(instancetype)shareInstance;
-(void)execute:(id)inparam URL:(NSString*)url Result:(void(^)(NSError *error,id obj))resultBlock;
@end
