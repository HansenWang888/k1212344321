#import <UIKit/UIKit.h>

@class SessionEntity;
@class AvatarImageView;
@class NameLabel;
@interface SessionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NameLabel *sessionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestSessionTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestSessionMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *distrubImabeView;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;

-(SessionEntity*)sessionEntity;
-(void)setSessionEntity:(SessionEntity*)sentity;
- (void)settelSubscribes;//设置公众号集合
@end