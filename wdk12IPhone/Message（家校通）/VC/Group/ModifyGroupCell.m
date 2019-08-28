#import "ModifyGroupCell.h"
#import "UIImageView+WebCache.h"


#import "ContactDataModel.h"
#define WHITE_INTERVAL 5.0


@interface ModifyGroupCell()
@property (weak, nonatomic) IBOutlet UIButton *CheckButton;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

@end


@implementation ModifyGroupCell

-(void)awakeFromNib{
    //static int i = 0;

    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = 5.0;
    
    _CheckButton.layer.cornerRadius = 10;
    _CheckButton.layer.masksToBounds = YES;
    
    _CheckButton.layer.borderWidth = 1.0;
    _CheckButton.layer.borderColor = [UIColor lightGrayColor].CGColor;

    _CheckButton.userInteractionEnabled = NO;
 //   self.userInteractionEnabled = YES;
    [_CheckButton setBackgroundImage:[UIImage imageNamed:@"checkIcon"] forState:UIControlStateSelected];
    
    
}

-(void)ButtonClicked{
    [_CheckButton setSelected:!_CheckButton.isSelected];
}
-(void)setChecked:(BOOL)check{
    [_CheckButton setSelected:check];
    
}
-(BOOL)Checked{
    return _CheckButton.isSelected;
}
-(void)updateUI{
    if(_userAbstrct == nil) return;
    
    [_avatarImageView sd_setImageWithURL: [NSURL URLWithString:ImageFullUrl(_userAbstrct.avatar)] placeholderImage:DEFAULT_AVATAR];

    // ret.imageView.image =
    _nickLabel.text = _userAbstrct.nick;

}
-(void)setUserAbstrct:(ContactUserAbstract *)userAbstrct{
    if(_userAbstrct == userAbstrct) return;
    _userAbstrct = userAbstrct;
    [self updateUI];
}
-(void)setSelectUser:(BOOL)selectUser{
    _selectUser = selectUser;
}
@end