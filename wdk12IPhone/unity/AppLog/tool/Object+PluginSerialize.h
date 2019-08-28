//
//  NSArray+PluginSerialize.h
//  MobileGateWay
//
//  Created by macapp on 17/3/17.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray(PluginSerialize)
+(NSMutableArray*)unserializeFromJsonValue:(NSArray*)ary Class:(Class)cls;
-(NSMutableArray*)serializeToJsonValue;

@end
@interface NSString(PluginSerialize)
+(NSString*)unserializeFromJsonValue:(NSString*)str Class:(Class)cls;
-(NSString*)serializeToJsonValue;

@end
@interface NSNumber(PluginSerialize)
+(NSString*)unserializeFromJsonValue:(NSNumber*)num Class:(Class)cls;
-(NSString*)serializeToJsonValue;
@end

@interface NSDictionary(PluginSerialize)
+(NSMutableDictionary*)unserializeFromJsonValue:(NSDictionary*)dic Class:(Class)cls;
-(NSMutableDictionary*)serializeToJsonValue;
@end
