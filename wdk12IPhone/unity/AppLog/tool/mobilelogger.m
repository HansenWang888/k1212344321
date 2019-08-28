#import "mobilelogger.h"
#import "MGPSession.h"
#pragma mark Uploadendlog_InParam
@implementation Uploadendlog_InParam
-(NSMutableDictionary*)serializeToJsonValue{
    NSMutableDictionary* obj = [NSMutableDictionary new];
    obj[@"logList"] = [self.m_loglist serializeToJsonValue];
    return obj;
}
+(Uploadendlog_InParam*)unserializeFromJsonValue:(NSMutableDictionary*) obj Class:(Class)cls;{
    Uploadendlog_InParam* retVal = [Uploadendlog_InParam new];
    retVal.m_loglist = [NSMutableArray unserializeFromJsonValue:obj[@"logList"] Class:[Mobilelogger_Loglist_sub class]];
    return retVal;
}
@end
@implementation Uploadendlog_Data
-(NSMutableDictionary*)serializeToJsonValue{
    NSMutableDictionary* obj = [NSMutableDictionary new];
    obj[@"rowCount"] = [self.m_rowcount serializeToJsonValue];
    return obj;
}
+(Uploadendlog_Data*)unserializeFromJsonValue:(NSMutableDictionary*) obj Class:(Class)cls;{
    Uploadendlog_Data* retVal = [Uploadendlog_Data new];
    retVal.m_rowcount = [NSString unserializeFromJsonValue:obj[@"rowCount"] Class:[NSString class]];
    return retVal;
}
@end
#pragma mark Uploadendlog_OutParam
@implementation Uploadendlog_OutParam
-(NSMutableDictionary*)serializeToJsonValue{
    NSMutableDictionary* obj = [NSMutableDictionary new];
    obj[@"data"] = [self.m_data serializeToJsonValue];
    obj[@"errcode"] = [self.m_errcode serializeToJsonValue];
    obj[@"errmsg"] = [self.m_errmsg serializeToJsonValue];
    return obj;
}
+(Uploadendlog_OutParam*)unserializeFromJsonValue:(NSMutableDictionary*) obj Class:(Class)cls;{
    Uploadendlog_OutParam* retVal = [Uploadendlog_OutParam new];
    retVal.m_data = [Uploadendlog_Data unserializeFromJsonValue:obj[@"data"] Class:[Uploadendlog_Data class]];
    retVal.m_errcode = [NSString unserializeFromJsonValue:obj[@"errcode"] Class:[NSString class]];
    retVal.m_errmsg = [NSString unserializeFromJsonValue:obj[@"errmsg"] Class:[NSString class]];
    return retVal;
}
@end
@implementation Mobilelogger
+(void)uploadendlog:(Uploadendlog_InParam*)inParam Result:(void(^)(NSError *error,Uploadendlog_OutParam* outParam))resultBlock{
    [[MGPSession shareInstance] execute:inParam URL:@"/uploadEndLog"  Result:^(NSError *error, id obj) {
        Uploadendlog_OutParam* outparam = [Uploadendlog_OutParam unserializeFromJsonValue:obj Class:[Uploadendlog_OutParam class]];
        if(resultBlock){
            resultBlock(error,outparam);
        }
    }];
}
@end
