// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import <ProtocolBuffers/ProtocolBuffers.h>

// @@protoc_insertion_point(imports)

@class IMHeartBeat;
@class IMHeartBeatBuilder;
@class IMPing;
@class IMPingBuilder;



@interface ImotherRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface IMHeartBeat : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
}

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (IMHeartBeatBuilder*) builder;
+ (IMHeartBeatBuilder*) builder;
+ (IMHeartBeatBuilder*) builderWithPrototype:(IMHeartBeat*) prototype;
- (IMHeartBeatBuilder*) toBuilder;

+ (IMHeartBeat*) parseFromData:(NSData*) data;
+ (IMHeartBeat*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMHeartBeat*) parseFromInputStream:(NSInputStream*) input;
+ (IMHeartBeat*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMHeartBeat*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (IMHeartBeat*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface IMHeartBeatBuilder : PBGeneratedMessageBuilder {
@private
  IMHeartBeat* resultImheartBeat;
}

- (IMHeartBeat*) defaultInstance;

- (IMHeartBeatBuilder*) clear;
- (IMHeartBeatBuilder*) clone;

- (IMHeartBeat*) build;
- (IMHeartBeat*) buildPartial;

- (IMHeartBeatBuilder*) mergeFrom:(IMHeartBeat*) other;
- (IMHeartBeatBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (IMHeartBeatBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

#define IMPing_localPingStart @"localPingStart"
#define IMPing_msgServerArrive @"msgServerArrive"
#define IMPing_DBProxyArrive @"dbproxyArrive"
#define IMPing_SqlStartTime @"sqlStartTime"
#define IMPing_SqlEndTime @"sqlEndTime"
#define IMPing_msgServerRspArrive @"msgServerRspArrive"
#define IMPing_localArrive @"localArrive"
#define IMPing_attach_data @"attachData"
@interface IMPing : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasLocalPingStart_:1;
  BOOL hasMsgServerArrive_:1;
  BOOL hasDbproxyArrive_:1;
  BOOL hasSqlStartTime_:1;
  BOOL hasSqlEndTime_:1;
  BOOL hasMsgServerRspArrive_:1;
  BOOL hasLocalArrive_:1;
  BOOL hasAttachData_:1;
  SInt64 localPingStart;
  SInt64 msgServerArrive;
  SInt64 dbproxyArrive;
  SInt64 sqlStartTime;
  SInt64 sqlEndTime;
  SInt64 msgServerRspArrive;
  SInt64 localArrive;
  NSData* attachData;
}
- (BOOL) hasLocalPingStart;
- (BOOL) hasMsgServerArrive;
- (BOOL) hasDbproxyArrive;
- (BOOL) hasSqlStartTime;
- (BOOL) hasSqlEndTime;
- (BOOL) hasMsgServerRspArrive;
- (BOOL) hasLocalArrive;
- (BOOL) hasAttachData;
@property (readonly) SInt64 localPingStart;
@property (readonly) SInt64 msgServerArrive;
@property (readonly) SInt64 dbproxyArrive;
@property (readonly) SInt64 sqlStartTime;
@property (readonly) SInt64 sqlEndTime;
@property (readonly) SInt64 msgServerRspArrive;
@property (readonly) SInt64 localArrive;
@property (readonly, strong) NSData* attachData;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (IMPingBuilder*) builder;
+ (IMPingBuilder*) builder;
+ (IMPingBuilder*) builderWithPrototype:(IMPing*) prototype;
- (IMPingBuilder*) toBuilder;

+ (IMPing*) parseFromData:(NSData*) data;
+ (IMPing*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMPing*) parseFromInputStream:(NSInputStream*) input;
+ (IMPing*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMPing*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (IMPing*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface IMPingBuilder : PBGeneratedMessageBuilder {
@private
  IMPing* resultImping;
}

- (IMPing*) defaultInstance;

- (IMPingBuilder*) clear;
- (IMPingBuilder*) clone;

- (IMPing*) build;
- (IMPing*) buildPartial;

- (IMPingBuilder*) mergeFrom:(IMPing*) other;
- (IMPingBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (IMPingBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasLocalPingStart;
- (SInt64) localPingStart;
- (IMPingBuilder*) setLocalPingStart:(SInt64) value;
- (IMPingBuilder*) clearLocalPingStart;

- (BOOL) hasMsgServerArrive;
- (SInt64) msgServerArrive;
- (IMPingBuilder*) setMsgServerArrive:(SInt64) value;
- (IMPingBuilder*) clearMsgServerArrive;

- (BOOL) hasDbproxyArrive;
- (SInt64) dbproxyArrive;
- (IMPingBuilder*) setDbproxyArrive:(SInt64) value;
- (IMPingBuilder*) clearDbproxyArrive;

- (BOOL) hasSqlStartTime;
- (SInt64) sqlStartTime;
- (IMPingBuilder*) setSqlStartTime:(SInt64) value;
- (IMPingBuilder*) clearSqlStartTime;

- (BOOL) hasSqlEndTime;
- (SInt64) sqlEndTime;
- (IMPingBuilder*) setSqlEndTime:(SInt64) value;
- (IMPingBuilder*) clearSqlEndTime;

- (BOOL) hasMsgServerRspArrive;
- (SInt64) msgServerRspArrive;
- (IMPingBuilder*) setMsgServerRspArrive:(SInt64) value;
- (IMPingBuilder*) clearMsgServerRspArrive;

- (BOOL) hasLocalArrive;
- (SInt64) localArrive;
- (IMPingBuilder*) setLocalArrive:(SInt64) value;
- (IMPingBuilder*) clearLocalArrive;

- (BOOL) hasAttachData;
- (NSData*) attachData;
- (IMPingBuilder*) setAttachData:(NSData*) value;
- (IMPingBuilder*) clearAttachData;
@end


// @@protoc_insertion_point(global_scope)
