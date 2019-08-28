#import "groupCell.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "GroupEntity.h"
#import "DDGroupModule.h"
#import "DDUserModule.h"
#import "UIImage+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "ViewSetUniversal.h"
#import <Masonry.h>

@interface GroupCell ()

@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;

@end
@implementation GroupCell
{
    NSString* _gid;
}
-(NSString*)GroupID{
    return _gid;
}
- (void)awakeFromNib {
//    UIView *vv = [UIView new];
//    vv.backgroundColor = [UIColor clearColor];
//    vv.bounds = self.frame;
//    UIView *selectedV = [[UIView alloc] init];
//    selectedV.backgroundColor =  COLOR_Creat(67, 79, 90, 1);
//    [vv addSubview:selectedV];
//    [selectedV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(vv).offset(8);
//        make.right.equalTo(vv).offset(-8);
//        make.top.bottom.equalTo(vv);
//    }];
//    self.selectedBackgroundView = vv;
}

-(void)setGroupID:(NSString*)gid{
    //NSLog(@"%p,%p",gid,_gid);
    if([_gid isEqualToString:gid]) return;
    _gid = gid;
    [_groupNameLabel setGid:gid];
    [_avatarImageView setGroupID:gid];
}
@end