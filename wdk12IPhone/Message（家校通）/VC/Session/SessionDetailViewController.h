//
#import <UIKit/UIKit.h>

@class SessionEntity;
@class AvatarImageView;
@class NameLabel;
@interface SessionDetailViewController : UIViewController 
@property (assign, nonatomic) BOOL isContactVC;//是否为联系人列表进入

-(id)initWithSession:(SessionEntity*)sentity;
- (instancetype)initWIthGroupID:(NSString *)groupID;
@end

@interface AvatarNickCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NameLabel *groupNameLabel;


-(void)setUserID:(NSString*)uid WithGroup:(NSString*)gid;

@end