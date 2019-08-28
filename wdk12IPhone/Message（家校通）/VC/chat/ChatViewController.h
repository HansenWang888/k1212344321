#import <UIKit/UIKit.h>
#import "RecorderManager.h"
#import "SubscribeMenuBar.h"
@class SessionEntity;
@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RecordingDelegate,SubscribeMenuDelegate>


+(instancetype)initWithSessionEntity:(SessionEntity*)sentity;
+(id)initWithUserID:(NSString*)uid;
+(id)initWithGroupID:(NSString*)gid;
+(id)initWithSubscribeID:(NSString*)sbid;
-(void)setSession:(SessionEntity*)sentity;
@end
