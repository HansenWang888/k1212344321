//
//  SearchSubscribeCell.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "SearchSubscribeCell.h"
#import "SubscribeEntity.h"
#import <UIImageView+WebCache.h>
#import "SubscribeModule.h"
#import "ChatHistoryVC.h"
#import "SessionEntity.h"
#import "SessionModule.h"
@interface SearchSubscribeCell ()
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNumberLsbel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgV;
@property (weak, nonatomic) IBOutlet UILabel *subDescLabel;

@end
@implementation SearchSubscribeCell

- (void)awakeFromNib {
    [self.addBtn setTitle:[NSString stringWithFormat:@"\U0000e625 %@", IMLocalizedString(@"关注", nil)] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
}

- (IBAction)getHistoryContentClick:(UIButton *)sender {
    //历史消息
    ChatHistoryVC* vc = [[ChatHistoryVC alloc] initWithSubscribeID:_subEntity.objID];
    vc.title = IMLocalizedString(@"历史消息", nil);
//    [g_SplitVC.rightNav pushViewController:vc animated:YES];
    [vc.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)addBtnClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:IMLocalizedString(@"请稍候", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[SubscribeModule shareInstance]attentionSubscribe:self.subEntity.objID Attention:SubscribeOptSubscribe Block:^(NSError *error) {
        if(!error){
            [SVProgressHUD showSuccessWithStatus:nil];
            weakSelf.addBtn.selected = YES;
            weakSelf.addBtn.backgroundColor = [UIColor grayColor];
        }
        else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"error=%@,code=%d",error.domain,error.code]];
        }
    }];
}

- (void)setSubEntity:(SubscribeEntity *)subEntity {
    _subEntity = subEntity;
    self.subNameLabel.text = subEntity.name;
    [self.avatarImgV sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(subEntity.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    self.subDescLabel.text = subEntity.introduce;
}

@end
