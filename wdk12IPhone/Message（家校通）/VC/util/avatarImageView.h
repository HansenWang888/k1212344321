
#import <UIKit/UIKit.h>


@interface AvatarImageView : UIImageView

-(void)makeBorder;

-(void)setUid:(NSString* )uid;
-(NSString*)Uid;
//-(void)setUids:(NSArray<NSString*>* )uids;
-(void)setGroupID:(NSString*)gid;
-(void)setSBID:(NSString*)sbid;
@end