//
//  JSONUtil.h
//  wdk12IPhone
//
//  Created by macapp on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FindKey)
-(id)recursiveObjectForKey:(id) key;
+(id)recursiveObjectForKey:(id) key Dic:(NSDictionary*) dic;



@end
