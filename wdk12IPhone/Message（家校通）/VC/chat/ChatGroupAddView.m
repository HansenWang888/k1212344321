//
//  ChatGroupAddView.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "ChatGroupAddView.h"
#import "GroupEntity.h"
#import "SessionEntity.h"
#import "DDGroupModule.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "UserInfoViewController.h"
#import "ModifyGroupMemberViewController.h"
#import "SessionDetailViewController.h"
#import <Masonry.h>

@interface ChatGroupAddView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
//@property (weak, nonatomic) IBOutlet UIButton *addBtn;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *others;

typedef void(^SetUniverseBlock)(AvatarNickCell*);
typedef void(^TouchUniverseBlock)(AvatarNickCell*);

typedef void(^Action)();
@end

@implementation ChatGroupAddView {

    BOOL _isWillHeigth;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static NSString *const CELL_ID = @"AvatarNickCell";
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.dataSource = self;
        self.delegate = self;
        
        [self registerNib:[UINib nibWithNibName:CELL_ID bundle:nil] forCellWithReuseIdentifier:CELL_ID];
        self.layer.borderWidth = 1;
        self.layer.borderColor = COLOR_Creat(229, 229, 229, 1).CGColor;
        self.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGroupUpdate:) name:DDNotificationGroupUpdated object:nil];
        _isWillHeigth = YES;
    }
    return self;
}
-(void)onGroupUpdate:(NSNotification*)notify{
    NSString* gid = [notify.object objectAtIndex:0];
    GroupNotifyType type = [[notify.object objectAtIndex:1] integerValue];
    
    if([gid isEqualToString:_sentity.sessionID]){
        if(type & GROUP_NOTIFY_MEMBER){
            [self initMemberDataModel];
            [self reloadData];
            NSInteger n = (self.frame.size.width-5)/69;
            NSInteger h;
            if(n!=0){
                h = _others.count/n + ((_others.count%n)>0?1:0) ;
            }
            else h =1;
            CGFloat height = MAX(104, h*84+20+(h-1)*10);
            
            CGRect frame = self.frame;
            frame.size.height = height;
            self.frame = frame;
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(height);
            }];
        }
    }
    
}
- (void)setSentity:(SessionEntity *)sentity {
    _sentity = sentity;
    [self initMemberDataModel];
}
-(void)initMemberDataModel{
    _others = [NSMutableArray new];
    
    BOOL couldadd = NO;
    BOOL coulddim = NO;
    GroupEntity* gentity = nil;
    WEAKSELF(self);
    if(_sentity.sessionType == SessionTypeSessionTypeGroup){
        gentity = [[DDGroupModule instance]getGroupInfoFromServerWithNotify:_sentity.sessionID Forupdate:NO];
        if(!gentity) return;
        
        for(NSInteger i = 0 ; i < gentity.groupUserIds.count ;++i){
            
            NSString* uid = gentity.groupUserIds[i];
            SetUniverseBlock setblock = ^(AvatarNickCell* cell){
                [cell setUserID:uid WithGroup:_sentity.sessionID];
            };
            TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
                if([uid isEqualToString:TheRuntime.user.objID]) return ;
                UserInfoViewController* vc = [[UserInfoViewController alloc]init];
                vc.isContactVC = NO;
                [vc setUserID:uid];
                if ([weakSelf.addDelegate respondsToSelector:@selector(chatGroupInfoUserWithVC:)]) {
                    [weakSelf.addDelegate chatGroupInfoUserWithVC:vc];
                }
            };
            
            [_others addObject:@{@"set":setblock,@"touch":touchblock}];
            //可添加
            if(!couldadd && [uid isEqualToString:TheRuntime.user.objID]) couldadd = YES;
        }
        if([gentity.groupCreatorId isEqualToString:TheRuntime.user.objID]){
            coulddim = YES;
        }
    }
    if(_sentity.sessionType == SessionTypeSessionTypeSingle){
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){
            [cell setUserID:_sentity.sessionID  WithGroup:nil];
        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            
            UserInfoViewController* vc = [[UserInfoViewController alloc]init];
            vc.isContactVC = NO;
            [vc setUserID:_sentity.sessionID];
            if ([weakSelf.addDelegate respondsToSelector:@selector(chatGroupInfoUserWithVC:)]) {
                [weakSelf.addDelegate chatGroupInfoUserWithVC:vc];
            }
        };
        [_others addObject:@{@"set":setblock,@"touch":touchblock}];
        couldadd = YES;
    }

    if(couldadd){
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){
            [cell.avatarImageView setImage:[UIImage imageNamed:@"sessionplus"]];
            [cell.avatarImageView setTintColor:[UIColor lightGrayColor]];
            cell.groupNameLabel.text = @"";
        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            //增加成员
            ModifyGroupMemberViewController* vc = [[ModifyGroupMemberViewController alloc]initWithSession:_sentity];
            if ([weakSelf.addDelegate respondsToSelector:@selector(chatGroupAddUserWithVC:)]) {
                [weakSelf.addDelegate chatGroupAddUserWithVC:vc];
            }
        };
        [_others addObject:@{@"set":setblock,@"touch":touchblock}];
    }
    if(coulddim){
    
        SetUniverseBlock setblock = ^(AvatarNickCell* cell){
            [cell.avatarImageView setImage:[UIImage imageNamed:@"sessiondim"]];
            [cell.avatarImageView setTintColor:[UIColor lightGrayColor]];
            cell.groupNameLabel.text = @"";
        };
        TouchUniverseBlock touchblock = ^(AvatarNickCell* cell){
            DelGroupMemberViewController* vc = [[DelGroupMemberViewController alloc]initWithGroup:gentity];
            //删除成员
            if ([self.addDelegate respondsToSelector:@selector(chatGroupDeleUserWithVC:)]) {
                [self.addDelegate chatGroupDeleUserWithVC:vc];
            }
        };
        [_others addObject:@{@"set":setblock,@"touch":touchblock}];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _others.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AvatarNickCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    SetUniverseBlock block =  (SetUniverseBlock)[_others[indexPath.row]objectForKey:@"set"];
    [cell.avatarImageView makeBorder];
    cell.backgroundColor = [UIColor whiteColor];
    block(cell);
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    
    if (_isWillHeigth) {
        _isWillHeigth = NO;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(collectionView.contentSize.height);
        }];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(64, 84);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 0);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TouchUniverseBlock block =  [_others[indexPath.row] objectForKey:@"touch"];
    NSLog(@"<#%@#>",indexPath);

    block(nil);
  
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
