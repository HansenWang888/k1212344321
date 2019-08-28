//
//  JSONUtil.m
//  wdk12IPhone
//
//  Created by macapp on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "NSDictionary+R.h"



id findVlueFromNsstring(NSString* key,NSString* str);
id findVlueFromNsdic(NSString* key,NSDictionary* dic);
id findVlueFromNsarray(NSString* key,NSArray* array);
id findValueFromObject(NSString* key, id unkonwobj){
    
    NSObject* obj  =  unkonwobj;
    if(obj == nil){
        return nil;
    }
    if([obj isKindOfClass:[NSString class]]){
        return  findVlueFromNsstring(key, unkonwobj);
      //  return obj;
    }
    else if ([obj isKindOfClass:[NSDictionary class]]){
        return findVlueFromNsdic(key, unkonwobj);
    }
    else if([obj isKindOfClass:[NSArray class]]){
        return findVlueFromNsarray(key, unkonwobj);
    }
    return nil;
}
id findVlueFromNsstring(NSString* key,NSString* str){
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:NSJSONReadingMutableContainers
                                               error:nil];
    
    return  findValueFromObject(key,obj);
}
id findVlueFromNsdic(NSString* key,NSDictionary* dic){
    __block NSObject* retv = [dic objectForKey:key];
    if(retv) return retv;
    [[dic allKeys]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [dic objectForKey:obj];
        retv = findValueFromObject(key, value);
        if(retv){
            *stop = YES;
        }
    }];
    
    return retv;
}
id findVlueFromNsarray(NSString* key,NSArray* array){
    __block NSObject* retv = nil;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        retv = findValueFromObject(key, obj);
        if(retv){
            *stop = YES;
        }
    }];
    return retv;
}

@implementation NSDictionary (FindKey)
-(id)recursiveObjectForKey:(id) key{
    return findVlueFromNsdic(key, self);
}
+(id)recursiveObjectForKey:(id) key Dic:(NSDictionary*) dic{
    return findVlueFromNsdic(key, dic);
}

@end


