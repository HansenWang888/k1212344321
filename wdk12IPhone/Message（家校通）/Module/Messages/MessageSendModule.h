#import <Foundation/Foundation.h>
#import "DDMessageEntity.h"
#import "SessionEntity.h"


typedef void(^MakeMessageCompeletion)(DDMessageEntity* msgentity);

@interface MessageSendModule : NSObject

+(MessageSendModule*)shareInstance;

-(BOOL)isInSendingQueue:(DDMessageEntity*)msgentity;

-(DDMessageEntity*)sendTextMessage:(NSString*)message Session:(SessionEntity*)sentity;

-(void)makeSubscribeMessage:(NSDictionary*)message Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;
-(void)makeRichTextMessage:(NSDictionary*)message Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;
-(void)sendImageMessage:(UIImage*)image  Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;
-(void)sendImageMessageWithUrl:(UIImage*)image Url:(NSURL*)url Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;
-(void)sendVoiceWithFilePath:(NSString*)filepath Length:(NSTimeInterval)length Session:(SessionEntity*)sentity Block:(MakeMessageCompeletion)block;



-(void)sendSubscribeInviteMessageToUser:(NSString*)uid SBID:(NSString*)sbid;
-(void)sendSubscribeInviteMessageToGroup:(NSString*)gid SBID:(NSString*)sbid;
-(void)resendMessage:(DDMessageEntity*)msgentity Session:(SessionEntity*)sentity;




@end


