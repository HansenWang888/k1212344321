#import "userAbstractCell.h"
#import "UIImageView+WebCache.h"
#import "DDUserModule.h"
#import "ContactModule.h"
#import "ViewSetUniversal.h"
#import "ContactDataModel.h"
#import "ContactModule.h"
#import "ModifySingleInfo.h"
#define WHITE_INTERVAL 5.0


@interface UserAbstractCell ()
@property (nonatomic, strong) UIButton *accessoryBtn;

@end
@implementation UserAbstractCell


//@dynamic userAbstrct;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 5.0;
    self.textLabel.font = [UIFont systemFontOfSize:15];
//    self.backgroundColor = [UIColor clearColor];
//    self.textLabel.textColor = [UIColor whiteColor];
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
    return self;
}
- (void)setIsAddAccessoryView:(BOOL)isAddAccessoryView {
//    if (isAddAccessoryView) {
//        self.accessoryView = self.accessoryBtn;
//    }
}
-(void)layoutSubviews{
    
    [super layoutSubviews];

    CGRect frame ;
    frame.origin.x = 15;
    frame.origin.y = 8;
    frame.size.height = self.frame.size.height - 2* frame.origin.y;
    frame.size.width = frame.size.height;
    self.imageView.frame = frame;
    
    CGRect oldframe = self.imageView.frame;
    
    CGFloat imageheight = self.frame.size.height-2*WHITE_INTERVAL;
    self.imageView.frame = CGRectMake(oldframe.origin.x, WHITE_INTERVAL, imageheight, imageheight);

    CGFloat textstartx = oldframe.origin.x*2+imageheight;
    self.textLabel.frame = CGRectMake(textstartx, 0, self.frame.size.width- textstartx,self.frame.size.height);
}
-(void)updateUI{
    if(_userAbstrct == nil) return;
    
    [self.imageView sd_setImageWithURL: [NSURL URLWithString:ImageFullUrl(_userAbstrct.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];

    self.textLabel.text = _userAbstrct.nick;

}
-(void)setUserAbstrct:(ContactUserAbstract *)userAbstrct{
    if(_userAbstrct == userAbstrct) return;
    _userAbstrct = userAbstrct;
    [self updateUI];
}
- (void)accessoryBtnClick {
    //加好友
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeGradient];
    [[ContactModule shareInstance]addUserToContact:_userAbstrct.uid Block:^(NSError * error) {
        if(!error){
            [SVProgressHUD showSuccessWithStatus:nil];
        }
        else{
            if(error.code == ContactModifyRetCodeNeetverify){
                [SVProgressHUD dismiss];
                //需要发送验证
                ModifySingleInfo* vc = [[ModifySingleInfo alloc]initWithModifyType:ModifySingleValueTypeVerify ObjectID:_userAbstrct.uid DefaultValue:[NSString stringWithFormat:@"%@ %@",IMLocalizedString(@"我是", nil),TheRuntime.user.nick ]];
                
//                [g_SplitVC.rightNav pushViewController:vc animated:YES];
//                [vc.navigationController setNavigationBarHidden:NO animated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
                NSLog(@"error:%@ code:%ld:",error.domain,error.code);
            }
        }
    }];

}

- (UIButton *)accessoryBtn {
    if (!_accessoryBtn) {
        _accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ViewSetUniversal setButton:_accessoryBtn title:[NSString stringWithFormat:@"\U0000e625 %@",IMLocalizedString(@"加好友", nil)] fontSize:16 textColor:nil fontName:@"iconfont" action:@selector(accessoryBtnClick) target:self];
        _accessoryBtn.backgroundColor = COLOR_Creat(94, 191, 109, 1);
        [ViewSetUniversal setView:_accessoryBtn cornerRadius:3];
        _accessoryBtn.bounds = CGRectMake(0, 0, 80, 35);
    }
    return _accessoryBtn;
}
@end
