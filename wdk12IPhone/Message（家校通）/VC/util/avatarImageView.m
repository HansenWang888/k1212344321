
#import "avatarImageView.h"
#import "UIImageview+webcache.h"
#import "DDUserModule.h"
#import "GroupEntity.h"
#import "DDGroupModule.h"
#import "ContactModule.h"
#import "SubscribeEntity.h"
#import "SubscribeModule.h"
@implementation AvatarImageView
{
    NSMutableArray<AvatarImageView*>* _imageViews;
    NSString* _uid;
    NSString* _gid;
    NSString* _sbid;
    NSInteger _count;
}

-(void)awakeFromNib{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
   // self.layer.borderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0].CGColor;
   // self.layer.borderWidth = 1.0;
   // [self reRect];
}
-(void)makeBorder{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)setGroupID:(NSString*)gid{
    assert(_uid == nil);
    if([_gid isEqualToString: gid]) return;
    _gid = gid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if(_gid == nil) return;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(groupUpdate:) name:DDNotificationGroupUpdated object:nil];
    [self groupUpdateImpl:gid];
}
-(void)setUid:(NSString* )uid{

    assert(_imageViews == nil);
    if([uid isEqualToString: _uid]) return;
    _uid = uid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if(_uid == nil) return;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userUpdate:) name:DDNotificationUserUpdated object:nil];
    [self userUpdateImpl:uid];
}
-(void)setSBID:(NSString*)sbid{
    assert(_gid == nil);
    assert(_uid == nil);
    if([_sbid isEqualToString:sbid]) return;
    _sbid = sbid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
    [self subscribeUpdateImpl:_sbid];
}
-(NSString*)Uid{
    return _uid;
}
-(void)userUpdate:(NSNotification*)notification{
    if([notification.object isEqualToString:_uid]){
        [self userUpdateImpl:notification.object];
    }
}
-(void)groupUpdate:(NSNotification*)notification{
    
    NSString* gid = [notification.object objectAtIndex:0];
    GroupNotifyType type = [[notification.object objectAtIndex:1] integerValue];
    if(type & GROUP_NOTIFY_MEMBER && [gid isEqualToString:_gid]){
        [self groupUpdateImpl:gid];
    }
    
}
-(void)groupUpdateImpl:(NSString*)gid{
    GroupEntity* gentity = [[DDGroupModule instance]getGroupInfoFromServerWithNotify:gid Forupdate:NO];
    if(gentity){
        NSRange range;
        range.location = 0;
        range.length = gentity.groupUserIds.count>9?9:gentity.groupUserIds.count;
        [self setUids:[gentity.groupUserIds subarrayWithRange:range]];
    }
}
-(void)userUpdateImpl:(NSString*)uid{
    DDUserEntity* uentity = [[ContactModule shareInstance]getUserInfoWithNotification:uid ForUpdate:NO];
    if(uentity){
        [self sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(uentity.avatar)] placeholderImage:DEFAULT_AVATAR];
    }
    else{
        self.image = DEFAULT_AVATAR;
    }
}
-(void)subscribeUpdate:(NSNotification*)notify{
    NSString* sbuuid = notify.object[0];
    if(![sbuuid isEqualToString:_sbid]) return;
    SubscribeUpdateType type = [notify.object[1] integerValue];
    
    if(type != SubscribeUpdateTypeInfo) return;
    [self subscribeUpdateImpl:_sbid];
}
-(void)subscribeUpdateImpl:(NSString*)sbid{
    
    SubscribeEntity* sbentity = [[SubscribeModule shareInstance]getSubscribeBySBID:sbid];
    if(sbentity != nil){
      
         [self sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(sbentity.avatar)] placeholderImage:DEFAULT_AVATAR];

    }
    else {
        self.image = DEFAULT_AVATAR;
    }
}
-(void)setUids:(NSArray<NSString*>* )uids{
    self.image = nil;
    if(_imageViews == nil) {
        _imageViews = [NSMutableArray new];
        for(int i = 0 ; i < 9 ; ++i){
            [_imageViews addObject:[AvatarImageView new]];
        }
        self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    }
    else{
        [_imageViews enumerateObjectsUsingBlock:^(AvatarImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            [obj setUid:nil];
        }];
    }
    _count = uids.count;
    
    [uids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_imageViews[idx] setUid:obj];
        [self addSubview:_imageViews[idx]];
    }];
    [self reRect];
}



-(void)layoutSubviews{
    [super layoutSubviews];
    [self reRect];
}
-(void)reRect{
    if(_imageViews == nil) return;
    switch(_count){
        case 1:[self init1];
            break;
        case 2:[self init2];
            break;
        case 3:[self init3];
            break;
        case 4:[self init4];
            break;
        case 5:[self init5];
            break;
        case 6:[self init6];
            break;
        case 7:[self init7];
            break;
        case 8:[self init8];
            break;
        case 9:[self init9];
            break;
        default:
            break;
    }
}

#define IMAGE_ORDER_START(_col,_frame,_imageWidth,_contentRadio,interval)  \
                   CGFloat width =  _frame.size.height*_contentRadio;    \
                   CGFloat xoffset =  _frame.size.height*(1-_contentRadio)*0.5;\
                   CGFloat imageWidth = _imageWidth*width;\
                   CGFloat xpos;\
                    CGFloat ypos;\
                    NSInteger index = 0; \
                    UIView* _view = nil;\
                    CGFloat _interval = interval/4.0;\
                    CGFloat _interval2 = interval/2.0;\
                    CGFloat yoffset = 0.0;\
                    CGRect frame = _frame;
#define SET_YOFFSET(_yoffset) yoffset = frame.size.height*_yoffset
#define ADD_IMAGE(_colindex,_xpos) \
                    xpos = xoffset+width*_xpos ;\
                    ypos = xoffset+(_colindex-1)*imageWidth+yoffset ;\
                    _view = _imageViews[index];\
                    ++index;\
                    _view.frame = CGRectMake(xpos+_interval,\
                    ypos+_interval,\
                    imageWidth-_interval2, imageWidth-_interval2) ;



#define IMAGE_ORDER_END

-(void)init1{
    IMAGE_ORDER_START(1, self.frame, 1.0, 0.9, 0);
    ADD_IMAGE(1, 0);
    IMAGE_ORDER_END;

}
-(void)init2{
    IMAGE_ORDER_START(1, self.frame, 0.5, 0.9, 3);
    SET_YOFFSET(0.25);
    ADD_IMAGE(1, 0);
    ADD_IMAGE(1, 0.5);
    IMAGE_ORDER_END;
}
-(void)init3{
    IMAGE_ORDER_START(1, self.frame, 0.5, 0.9, 2);
    ADD_IMAGE(1, 0.25);
    ADD_IMAGE(2, 0);
    ADD_IMAGE(2, 0.5);
    IMAGE_ORDER_END;
}
-(void)init4{
    IMAGE_ORDER_START(2, self.frame, 0.5, 0.9,2);
    ADD_IMAGE(1, 0);
    ADD_IMAGE(1, 0.5);
    ADD_IMAGE(2, 0);
    ADD_IMAGE(2, 0.5);
    IMAGE_ORDER_END;

}
-(void)init5{
    IMAGE_ORDER_START(2, self.frame,0.333,0.9,1);
    SET_YOFFSET(0.1167);
    ADD_IMAGE(1, 0.167);
    ADD_IMAGE(1, 0.5);
    ADD_IMAGE(2, 0.0);
    ADD_IMAGE(2, 0.333);
    ADD_IMAGE(2, 0.666);
    IMAGE_ORDER_END;
    
}
-(void)init6{
    IMAGE_ORDER_START(2, self.frame,0.333,0.9,1);
    SET_YOFFSET(0.1167);
    ADD_IMAGE(1, 0.0);
    ADD_IMAGE(1, 0.333);
    ADD_IMAGE(1, 0.666);
    ADD_IMAGE(2, 0.0);
    ADD_IMAGE(2, 0.333);
    ADD_IMAGE(2, 0.666);
    IMAGE_ORDER_END;
}
-(void)init7{
    IMAGE_ORDER_START(3, self.frame,0.333,0.9,1);
    ADD_IMAGE(1, 0.0);
    ADD_IMAGE(1, 0.333);
    ADD_IMAGE(1, 0.666);
    ADD_IMAGE(2, 0.0);
    ADD_IMAGE(2, 0.333);
    ADD_IMAGE(2, 0.666);
    ADD_IMAGE(3, 0.333);
    IMAGE_ORDER_END;
}
-(void)init8{
    IMAGE_ORDER_START(3, self.frame,0.333,0.9,1);
    ADD_IMAGE(1, 0.0);
    ADD_IMAGE(1, 0.333);
    ADD_IMAGE(1, 0.666);
    ADD_IMAGE(2, 0.0);
    ADD_IMAGE(2, 0.333);
    ADD_IMAGE(2, 0.666);
    ADD_IMAGE(3, 0.167);
    ADD_IMAGE(3, 0.5);
    IMAGE_ORDER_END;
}
-(void)init9{
    IMAGE_ORDER_START(3, self.frame,0.333,0.9,1);
    ADD_IMAGE(1, 0.0);
    ADD_IMAGE(1, 0.333);
    ADD_IMAGE(1, 0.666);
    ADD_IMAGE(2, 0.0);
    ADD_IMAGE(2, 0.333);
    ADD_IMAGE(2, 0.666);
    ADD_IMAGE(3, 0.0);
    ADD_IMAGE(3, 0.333);
    ADD_IMAGE(3, 0.666);
    IMAGE_ORDER_END;
}
@end