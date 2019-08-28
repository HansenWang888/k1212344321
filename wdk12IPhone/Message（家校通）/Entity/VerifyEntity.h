#ifndef _verify_entity_h
#define _verify_entity_h


#import "DDBaseEntity.h"
#import "IMBaseDefine.pb.h"

@interface VerifyEntity : DDBaseEntity

@property NSString* verify;

-(id)initWithPB:(VerifyInfo *)pverify;

+(NSString *)pbUserIdToLocalID:(NSUInteger)Id;
@end



#endif