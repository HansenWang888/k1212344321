
#import <UIKit/UIKit.h>


@class ContactUserAbstract;
@interface UserAbstractCell : UITableViewCell


@property(nonatomic) ContactUserAbstract* userAbstrct;

@property (assign, nonatomic) BOOL isAddAccessoryView;//自定义accessoryView

@end