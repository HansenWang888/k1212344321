//
//  MessageTableView.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ContactTableView.h"
#import "UIColor+Hex.h"
#import "ContactModule.h"
#import "DDUserModule.h"
#import "userAbstractCell.h"
#import "UIImageView+WebCache.h"
#import "ContactDataModel.h"
#import "ModifyGroupMemberViewController.h"
#define PREFIX_SECTION 1


@interface ContactTableView ()
@property (nonatomic, weak) UITableViewCell *lastCell;
@property (nonatomic, copy) NSArray *sectionData;
@property (nonatomic, strong) UILabel *friendLabel;


@end
@implementation ContactTableView
{
    BOOL _reg;
    ContactDataModel* _dataModel;
}

-(id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(verifyListUpdateNotification) name:DDNotificationVerifyListRefresh object:nil];
    _dataModel = [[ContactDataModel alloc ]initWithTableView:self SectionStart:PREFIX_SECTION];
    self.backgroundView = [[UIView alloc]init];
    self.dataSource = self;
    self.delegate = self;
    
    self.tableFooterView = [UIView new];
    
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.sectionIndexColor = [UIColor grayColor];//导航字母的颜色
    self.sectionIndexBackgroundColor = [UIColor clearColor];
//    self.separatorColor = [UIColor clearColor];
//    self.sectionIndexColor = [UIColor grayColor];//导航字母的颜色
//    self.sectionIndexBackgroundColor = COLOR_Creat(50, 58, 67, 1);
    self.sectionData = @[
                         @{@"text": IMLocalizedString(@"新朋友", nil), @"image":[UIImage imageNamed:@"newfriend"]},
                         @{@"text": IMLocalizedString(@"会话组", nil), @"image":[UIImage imageNamed:@"groupsession"]},
                         @{@"text": IMLocalizedString(@"公众号", nil), @"image":[UIImage imageNamed:@"SB-H"]}
                         ];
    [self verifyListUpdateNotification];

    return self;
}
- (void)verifyListUpdateNotification {
    NSArray *list = [[ContactModule shareInstance] getAllVerify];
    if (list.count > 0) {
        self.friendLabel.hidden = NO;
    } else {
        self.friendLabel.hidden = YES;
    }
}
- (void)awakeFromNib {
    _dataModel = [[ContactDataModel alloc ]initWithTableView:self SectionStart:PREFIX_SECTION];
    self.backgroundView = [[UIView alloc]init];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.tableFooterView = [UIView new];
  
}

-(void)reloadData{
    [_dataModel reload];
    [super reloadData];
}
#pragma mark TABLE_VIEW_DATASOURCE
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return PREFIX_SECTION+[_dataModel LetterCount];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return self.sectionData.count;
    else{
        NSInteger rownum = [_dataModel UserAbstractsForSection:section].count;
        return rownum;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        UITableViewCell* ret = nil;
        ret = [self dequeueReusableCellWithIdentifier:@"groupsession"];
       
        if(ret) return ret;
        ret = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupsession"];
        if (indexPath.row == 0) {
            ret.accessoryView  = self.friendLabel;
        }
        ret.imageView.image = self.sectionData[indexPath.row][@"image"];
        if (indexPath.row != 2) {
            ret.imageView.image = [ret.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [ret.imageView setTintColor:[UIColor ColorWithHexRGBA:@"#3DA99DFF"]];
        }
        ret.textLabel.text = self.sectionData[indexPath.row][@"text"];
        ret.textLabel.font = [UIFont systemFontOfSize:15];
        return ret;
    }
    NSString* CELL_ID = @"userabstractcell";
    UserAbstractCell* ret = nil;
    if(_reg == NO){
        [self registerClass:[UserAbstractCell class] forCellReuseIdentifier:CELL_ID];
        _reg = YES;
    }
    if (self.lastCell) {
        NSIndexPath *index = [tableView indexPathForCell:self.lastCell];
        if (indexPath.row == index.row) {
            [tableView selectRowAtIndexPath:index animated:NO scrollPosition:0];
        }
    }
    ContactUserAbstract* userabstract = nil;
    userabstract = [_dataModel UserAbstractForIndexPath:indexPath];
    assert(userabstract);
    ret = [self dequeueReusableCellWithIdentifier:CELL_ID];
    
    ret.userAbstrct = userabstract;
    return ret;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
    if(section>=PREFIX_SECTION){
        
        return  [NSString stringWithFormat:@"  %@",[_dataModel FLForSection:section]];
    }
    else return nil;
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return [_dataModel Letters];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    UITableViewHeaderFooterView *head = (UITableViewHeaderFooterView *)view;
    head.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    head.textLabel.textColor = [UIColor grayColor];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{

    return index+PREFIX_SECTION;
}

#pragma mark TABLE_VIEW_DELEGET

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    currentCell.selected = YES;
//    if (currentCell == self.lastCell && indexPath.section != 0) {
//        return;
//    }
//    self.lastCell = currentCell;
//
//    if(_contactTableViewdelegate == nil) return;
    UserAbstractCell* cell = [self cellForRowAtIndexPath:indexPath];

    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                if (indexPath.row == 0) {
                    if([_contactTableViewdelegate respondsToSelector:@selector(GroupTouched)]){
                        [_contactTableViewdelegate NewFriendTouched];
                    }
                break;
            case 1:
                    if([_contactTableViewdelegate respondsToSelector:@selector(GroupTouched)]){
                        [_contactTableViewdelegate GroupTouched];
                    }
                break;
            case 2:
                    if([_contactTableViewdelegate respondsToSelector:@selector(SubscribeTouched)]){
                        [_contactTableViewdelegate SubscribeTouched];
                    }
                break;
               
                }
        }
    }

    else{
        assert(cell.userAbstrct != nil);
        if([_contactTableViewdelegate respondsToSelector:@selector(UserTouched:)]){
            [_contactTableViewdelegate UserTouched:cell.userAbstrct.uid];
        }
    }
}
- (UILabel *)friendLabel {
    if (!_friendLabel) {
        _friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _friendLabel.backgroundColor = [UIColor redColor];
        _friendLabel.layer.cornerRadius = 5;
        _friendLabel.layer.masksToBounds = YES;
        _friendLabel.hidden = YES;
    }
    return _friendLabel;
}
@end
