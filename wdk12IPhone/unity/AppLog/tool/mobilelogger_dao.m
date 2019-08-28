#import "mobilelogger_dao.h"
@implementation Mobilelogger_Loglist_sub
-(NSMutableDictionary*)serializeToJsonValue{
    NSMutableDictionary* obj = [NSMutableDictionary new];
    obj[@"appID"] = [self.m_appid serializeToJsonValue];
    obj[@"appVersion"] = [self.m_appversion serializeToJsonValue];
    obj[@"content"] = [self.m_content serializeToJsonValue];
    obj[@"digest"] = [self.m_digest serializeToJsonValue];
    obj[@"end"] = [self.m_end serializeToJsonValue];
    obj[@"endInfo"] = [self.m_endinfo serializeToJsonValue];
    obj[@"endLogTime"] = [self.m_endlogtime serializeToJsonValue];
    obj[@"endOs"] = [self.m_endos serializeToJsonValue];
    obj[@"recorder"] = [self.m_recorder serializeToJsonValue];
    obj[@"type"] = [self.m_type serializeToJsonValue];
    return obj;
}
+(Mobilelogger_Loglist_sub*)unserializeFromJsonValue:(NSMutableDictionary*) obj Class:(Class)cls;{
    Mobilelogger_Loglist_sub* retVal = [Mobilelogger_Loglist_sub new];
    retVal.m_appid = [NSString unserializeFromJsonValue:obj[@"appID"] Class:[NSString class]];
    retVal.m_appversion = [NSString unserializeFromJsonValue:obj[@"appVersion"] Class:[NSString class]];
    retVal.m_content = [NSString unserializeFromJsonValue:obj[@"content"] Class:[NSString class]];
    retVal.m_digest = [NSString unserializeFromJsonValue:obj[@"digest"] Class:[NSString class]];
    retVal.m_end = [NSString unserializeFromJsonValue:obj[@"end"] Class:[NSString class]];
    retVal.m_endinfo = [NSString unserializeFromJsonValue:obj[@"endInfo"] Class:[NSString class]];
    retVal.m_endlogtime = [NSString unserializeFromJsonValue:obj[@"endLogTime"] Class:[NSString class]];
    retVal.m_endos = [NSString unserializeFromJsonValue:obj[@"endOs"] Class:[NSString class]];
    retVal.m_recorder = [NSString unserializeFromJsonValue:obj[@"recorder"] Class:[NSString class]];
    retVal.m_type = [NSString unserializeFromJsonValue:obj[@"type"] Class:[NSString class]];
    return retVal;
}
@end
