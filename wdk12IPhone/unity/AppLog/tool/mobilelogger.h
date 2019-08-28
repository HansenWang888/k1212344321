#import <Foundation/Foundation.h>
#import "MGPSerializeProtocol.h"
#import "mobilelogger_dao.h"
#pragma mark Uploadendlog_InParam
@interface Uploadendlog_InParam : NSObject<PluginSerialize>
@property (nonatomic) NSMutableArray<Mobilelogger_Loglist_sub*>* m_loglist;
@end
@interface Uploadendlog_Data : NSObject<PluginSerialize>
@property (nonatomic) NSString* m_rowcount;
@end
#pragma mark Uploadendlog_OutParam
@interface Uploadendlog_OutParam : NSObject<PluginSerialize>
@property (nonatomic) Uploadendlog_Data* m_data;
@property (nonatomic) NSString* m_errcode;
@property (nonatomic) NSString* m_errmsg;
@end
@interface Mobilelogger : NSObject
+(void)uploadendlog:(Uploadendlog_InParam*)inParam Result:(void(^)(NSError *error,Uploadendlog_OutParam* outParam))resultBlock;
@end
