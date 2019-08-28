#import <Foundation/Foundation.h>
#import "MGPSerializeProtocol.h"
@class Mobilelogger_Loglist_sub;
@interface Mobilelogger_Loglist_sub : NSObject<PluginSerialize>

@property (nonatomic) NSString* m_appid;
@property (nonatomic) NSString* m_appversion;
@property (nonatomic) NSString* m_content;
@property (nonatomic) NSString* m_digest;
@property (nonatomic) NSString* m_end;
@property (nonatomic) NSString* m_endinfo;
@property (nonatomic) NSString* m_endlogtime;
@property (nonatomic) NSString* m_endos;
@property (nonatomic) NSString* m_recorder;
@property (nonatomic) NSString* m_type;
@end
