#import "ContactInfo.h"
#import "GroupEntity.h"

@implementation ContactInfoEntity

-(id)initWithPB:(ContactInfo *)pinfo{
    self = [super init];
    if(self){
               //self.rmkname = pinfo.verify;
    
        if([pinfo hasRmkname]) {
           self.rmkname = pinfo.rmkname;
   
        }
        else self.rmkname = @"";
        self.lastUpdateTime = pinfo.latestUpdateTime;
        self.type = pinfo.type;
        
        if(self.type == 2){
            self.objID = [GroupEntity pbGroupIdToLocalID :pinfo.id];
        }
        else{
            self.objID = [DDUserEntity pbUserIdToLocalID:pinfo.id];
        }
        self.status = pinfo.status;
    }
    return  self;
}
-(id)initWithUid:(NSString*)uid{
    self = [super init];
    self.objID = uid;
    self.rmkname = @"";
    self.lastUpdateTime = 0;
    self.status = 0;
    self.type = 1;
    return self;
}
-(id)initWithGid:(NSString*)gid{
    self = [super init];
    self.objID = gid;
    self.rmkname = @"";
    self.lastUpdateTime = 0;
    self.status = 0;
    self.type = 2;
    return self;
}
-(BOOL)hasRmkname{
    if(_rmkname && ![_rmkname isEqualToString:@""]){
        return YES;
    }
    return NO;
}
-(BOOL)isContactUser{
    if(_type == 1 && _status == 0) return YES;
    return NO;
}
-(BOOL)isContactGroup{
    if(_type == 2 && _status == 0) return YES;
    return NO;
}
@end