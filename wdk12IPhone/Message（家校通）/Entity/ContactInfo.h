#ifndef _contact_info_entity_h
#define _contact_info_entity_h



#import "DDBaseEntity.h"
#import "IMBaseDefine.pb.h"

@interface ContactInfoEntity : DDBaseEntity

@property NSString* rmkname;
@property NSInteger type;
@property NSInteger status;

-(id)initWithPB:(ContactInfo *)pinfo;
-(BOOL)hasRmkname;
-(BOOL)isContactUser;
-(BOOL)isContactGroup;

-(id)initWithUid:(NSString*)uid;
-(id)initWithGid:(NSString*)gid;
@end



#endif