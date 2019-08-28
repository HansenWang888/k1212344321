//
//  NSArray+PluginSerialize.m
//  MobileGateWay
//
//  Created by macapp on 17/3/17.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import "Object+PluginSerialize.h"

BOOL notNullObj(id obj){
    if(obj == nil) return false;
    if([obj class] == [NSNull class]) return false;
    return true;
}

@implementation NSArray(PluginSerialize)
+(NSMutableArray*)unserializeFromJsonValue:(NSArray*)ary Class:(Class)cls{
    
    NSMutableArray* ret = [NSMutableArray new];
    if(notNullObj(ary)) return ret;
    [ary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj class] == [NSDictionary class]){
            
            [ret addObject: [cls unserializeFromJsonValue:obj Class:cls]];
        }
        else{
            [ret addObject:[[obj class] unserializeFromJsonValue:obj Class:cls]];
        }
        
    }];
    return ret;
}
-(NSMutableArray*)serializeToJsonValue{
    NSMutableArray* ret = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:[obj serializeToJsonValue]];
    }];
    return  ret;
}

@end
@implementation NSString(PluginSerialize)
+(NSString*)unserializeFromJsonValue:(NSString*)str Class:(Class)cls{
    
   // return notNullObj(str)?str:@"";
    return notNullObj(str)?[NSString stringWithFormat:@"%@",str]:@"";
}
-(NSString*)serializeToJsonValue{
    return self;
}

@end
@implementation NSNumber(PluginSerialize)
+(NSString*)unserializeFromJsonValue:(NSNumber*)num Class:(Class)cls{
    return notNullObj(num)?[num stringValue]:@"";
}
-(NSString*)serializeToJsonValue{
    return [self stringValue];
}
@end

@implementation NSDictionary(PluginSerialize)
+(NSMutableDictionary*)unserializeFromJsonValue:(NSDictionary*)dic Class:(Class)cls{
    return [[NSMutableDictionary alloc]initWithDictionary:dic];
}
-(NSMutableDictionary*)serializeToJsonValue{
    return [[NSMutableDictionary alloc]initWithDictionary:self];
}
@end


