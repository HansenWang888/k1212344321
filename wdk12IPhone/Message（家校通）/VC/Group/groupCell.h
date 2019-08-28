#import <UIKit/UIKit.h>

@class NameLabel;
@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NameLabel *groupNameLabel;

-(NSString*)GroupID;
-(void)setGroupID:(NSString*)gid;

@end