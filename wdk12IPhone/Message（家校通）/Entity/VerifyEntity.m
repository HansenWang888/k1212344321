#import "VerifyEntity.h"
#import "DDUserEntity.h"
#define VERIFY_PRE @"verify_"
@implementation VerifyEntity

+(NSString *)pbUserIdToLocalID:(NSUInteger)Id
{
    return [NSString stringWithFormat:@"%@%ld",VERIFY_PRE,Id];
}

-(id)initWithPB:(VerifyInfo *)pverify{
    self = [super init];
    if(self){
        self.objID = [DDUserEntity pbUserIdToLocalID:pverify.fromUserId];
        self.verify = pverify.verify;
        self.lastUpdateTime = 0;
    }
    return  self;
}

@end