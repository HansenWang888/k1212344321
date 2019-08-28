#import "verifyCell.h"
#import "DDUserModule.h"
#import "ContactModule.h"
#import "UIImageView+WebCache.h"
@interface VerifyCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;

@property (weak, nonatomic) IBOutlet UILabel *nickLable;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@end

@implementation VerifyCell
{
    NSString* _verify;
    NSString* _uid;
}
-(void)awakeFromNib{
    _avatarImageView.layer.cornerRadius = 10.0;
    _avatarImageView.layer.masksToBounds = YES;
    self.agreeBtn.layer.cornerRadius = 3;
    self.agreeBtn.layer.masksToBounds = YES;
    self.refuseBtn.layer.cornerRadius = 3;
    self.refuseBtn.layer.masksToBounds = YES;
}
-(void)setUidAndVerify:(NSString*)uid Verify:(NSString*)verify{
    if([_uid isEqualToString:uid]) return;
    _uid = uid;
    _verify = verify;
    _verifyLabel.text = verify;
    
    DDUserEntity* uentity =  [[DDUserModule shareInstance]getUserByID:uid];
    
    if(!uentity) {
        [_avatarImageView setImage:[UIImage imageNamed:@"defualtAvatar"]];
        [[ContactModule shareInstance]GetUsersInfoFromServer:@[uid]  Block:^(NSError *error, NSArray *userlist) {
            if(!error && userlist.count> 0){
                [userlist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[DDUserModule shareInstance]addMaintanceUser:obj];
                }];
                
                [self setupUI:[userlist objectAtIndex:0]];
            }
        }];
    }
    else{
        [self setupUI:uentity];
    }
    
}
- (IBAction)btnClick:(UIButton *)sender {
    if (sender == self.agreeBtn) {
        if ([self.verifyDelegate respondsToSelector:@selector(agreeAddition:)]) {
            [self.verifyDelegate agreeAddition:_uid];
        }
    } else {
        if ([self.verifyDelegate respondsToSelector:@selector(refuseAddition:)]) {
            [self.verifyDelegate refuseAddition:_uid];
        }
    }
}
-(void)setupUI:(DDUserEntity*)uentity{
    assert(uentity);
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(uentity.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    
    _nickLable.text = uentity.nick;
    
}
-(NSString*)UserID{
    return _uid;
}
@end