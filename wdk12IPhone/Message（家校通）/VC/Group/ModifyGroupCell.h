
#import <UIKit/UIKit.h>


@class ContactUserAbstract;
@interface ModifyGroupCell : UITableViewCell


@property(nonatomic) ContactUserAbstract* userAbstrct;
@property(nonatomic) BOOL selectUser;

-(void)setChecked:(BOOL)check;
-(BOOL)Checked;

@end