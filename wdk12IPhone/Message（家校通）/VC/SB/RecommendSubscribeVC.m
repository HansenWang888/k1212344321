//
//  RecommendSubscribeVC.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "RecommendSubscribeVC.h"
#import "userAbstractCell.h"
#import "ContactModule.h"
#import "ContactInfo.h"
#import "DDUserModule.h"
#import "ContactDataModel.h"
#import "MessageSendModule.h"
#import "DDGroupModule.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "groupCell.h"
#import "nameLabel.h"
@interface RecommendSubscribeVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *contacts;
@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, strong) NSMutableSet *userSelecteds;

@property (nonatomic, strong) NSMutableSet *groupSelecteds;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@end
#define PREFIX_SECTION 1
@implementation RecommendSubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.title = IMLocalizedString(@"公众号推荐",nil);
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UserAbstractCell class] forCellReuseIdentifier:@"userCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupCell" bundle:nil] forCellReuseIdentifier:@"GroupCell"];
    NSMutableArray *arrayM = @[].mutableCopy;
    self.contacts = [[ContactModule shareInstance] GetContactUser].copy;
    for (ContactInfoEntity *entity in [[ContactModule shareInstance] GetContactUser]) {
        DDUserEntity *user = [[DDUserModule shareInstance] getUserByID:entity.objID];
        ContactUserAbstract *userAbstract = [[ContactUserAbstract alloc] initWithUserEntityAndContactInfoEntity:user ContactInfoEntity:entity];
        [arrayM addObject:userAbstract];
    }
    self.contacts = arrayM.copy;
    NSArray *contactGroups = [[ContactModule shareInstance] GetContactGroup];
    NSMutableArray *sessions = @[].mutableCopy;
    for (SessionEntity *entity in [[SessionModule sharedInstance] getAllSessions]) {
        if (entity.isGroup) {
            [sessions addObject:entity];
        }
    }
    NSMutableDictionary *dictM = @{}.mutableCopy;
    [contactGroups enumerateObjectsUsingBlock:^(ContactInfoEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dictM setObject:obj.objID forKey:obj.objID];
    }];
    [sessions enumerateObjectsUsingBlock:^(SessionEntity *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dictM setObject:obj.sessionID forKey:obj.sessionID];
    }];
    self.groups = dictM.allValues;
    self.userSelecteds = [NSMutableSet set];
    self.groupSelecteds = [NSMutableSet set];
    if (self.contacts.count == 0 && self.groups.count == 0) {
        [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"你还没有可以推荐的用户和群组", nil)];
    }
}
- (IBAction)canaleSeletedClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)attentionClick:(id)sender {
       if (self.userSelecteds.count != 0 || self.groupSelecteds.count != 0) {
        for (NSString *objID in self.userSelecteds) {
            [[MessageSendModule shareInstance] sendSubscribeInviteMessageToUser:objID SBID:self.subscribeID];
        }
        for (NSString *objID in self.groupSelecteds) {
            [[MessageSendModule shareInstance] sendSubscribeInviteMessageToGroup:objID SBID:self.subscribeID];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
           
    } else {
        [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"请选择", nil)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        
        return self.contacts.count;
    }
    return self.groups.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UserAbstractCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userAbstrct = self.contacts[indexPath.row];
        return cell;
    } else {
        GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        [cell setGroupID:self.groups[indexPath.row]];
        cell.groupNameLabel.textColor = [UIColor blackColor];
        return cell;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        ContactUserAbstract *user = self.contacts[indexPath.row];
        UserAbstractCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = (cell.accessoryType==UITableViewCellAccessoryCheckmark) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        [self.userSelecteds addObject:user.uid];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [self.userSelecteds removeObject:user.uid];
        }
    } else {
        GroupCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = (cell.accessoryType==UITableViewCellAccessoryCheckmark) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        [self.groupSelecteds addObject:self.groups[indexPath.row]];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return (self.contacts.count > 0) ? IMLocalizedString(@"用户", nil) : @"";
    }
    return self.groups.count > 0 ? IMLocalizedString(@"群组", nil) : @"";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
