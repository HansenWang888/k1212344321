#import "ContactDataModel.h"
#import "ContactModule.h"
#import "DDUserModule.h"
@implementation ContactUserAbstract

-(id)initWithUserEntityAndContactInfoEntity:( DDUserEntity*) user
                          ContactInfoEntity:( ContactInfoEntity*) cinfo{
    
    assert(user != nil || cinfo != nil);
    self = [super init];
    _uid = cinfo?cinfo.objID:user.objID;
    
    
    
    if(user != nil){
        _nick = user.nick;
        _avatar = user.avatar;
    }
    else{
        _nick = @"";
        _avatar = @"";
    }
    
    if(cinfo && [cinfo hasRmkname]) _nick = cinfo.rmkname;
    
    return self;
}
-(NSComparisonResult)compare:(ContactUserAbstract*)other{
    NSLog(@"call compare::::::::::");
    
    if(other == self) return NSOrderedSame;
    return [_uid compare:other.uid];
}

@end


@implementation FlMapData



@end


@implementation ContactDataModel
{
    NSMutableArray<NSString*>* _excludes;
    //uid->fl
    NSMutableDictionary<NSString* ,NSNumber*>*   _uids;
    //auto sort
    NSMutableArray<FlMapData* >*   _datas;
    __weak UITableView*            _tableView;
    NSInteger               _sectionStart;
    BOOL                    _first;
}
-(id)initWithTableView:(UITableView*)tablview SectionStart:(NSInteger)sectionStart{
    self = [super init];
    
    _uids = [NSMutableDictionary new];
    _datas = [NSMutableArray new];
    
    _sectionStart = sectionStart;
    _tableView = tablview;
    
    _first = YES;
    _excludes = [NSMutableArray new];
    return self;
}
-(id)initWithTableView:(UITableView *)tablview SectionStart:(NSInteger)sectionStart Excludes:(NSArray<NSString*>*) uids{
    self = [super init];
    
    _uids = [NSMutableDictionary new];
    _datas = [NSMutableArray new];
    
    _sectionStart = sectionStart;
    _tableView = tablview;
    
    _first = YES;
    _excludes = [[NSMutableArray alloc]initWithArray:uids];
    return self;
}
-(NSArray*)excludes{
    return _excludes;
}
-(void)onFirstReload{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UserUpdated:) name:DDNotificationUserUpdated object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)reload{
    
    [_uids   removeAllObjects];
    [_datas removeAllObjects];
    [[[ContactModule shareInstance] GetContactUser]enumerateObjectsUsingBlock:^(ContactInfoEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if([_excludes containsObject:obj.objID]) return ;
        
        DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:obj.objID];
        [self Insert:obj UserEntity:uentity WithAnimate:NO ];
    }];
    if(_first == YES){
        _first = NO;
        [self onFirstReload];
    }
    
}

-(void)UserUpdated:(NSNotification*)notify{
    
    NSString* uid = notify.object;
    assert(uid);
    
    if([_excludes containsObject:uid]) return;
    
    if([[ContactModule shareInstance]IsContactUser:uid]){
        DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:uid];
        ContactInfoEntity* centity = [[ContactModule shareInstance]GetContactInfoByID:uid];
        
        assert(centity);
        [self Insert:centity UserEntity:uentity WithAnimate:YES];
        
    }
    else if ([_uids objectForKey:uid] != nil){
        NSNumber* fl = [_uids objectForKey:uid];
        NSIndexPath* indexpath = [self GetUserAbstractByUserIDAndFl:fl UID:uid];
        assert(indexpath);
        NSIndexPath* toremove = [NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section+_sectionStart];
        
        [_tableView beginUpdates];

        
        FlMapData* flmapdata = _datas[indexpath.section];
        [flmapdata._datas removeObjectAtIndex:indexpath.row];
        if(flmapdata._datas.count == 0) {
            [_datas removeObjectAtIndex:indexpath.section];
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:toremove.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            [_tableView deleteRowsAtIndexPaths:@[toremove] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [_tableView endUpdates];
        [_uids removeObjectForKey:uid];
        
    }
    else{
        //lose Interesting
    }
}
-(void)Insert:(ContactInfoEntity*)centity UserEntity:(DDUserEntity*)uentity WithAnimate:(BOOL)animate{
    ContactUserAbstract* data = [[ContactUserAbstract alloc]initWithUserEntityAndContactInfoEntity:uentity ContactInfoEntity:centity];
    
    NSNumber* fl = [_uids objectForKey:centity.objID];
    //新的用户,但是不一定是新的首字母
    if(fl == nil){
        [self InsertNew:data Animated:animate];
    }
    else{
        [self ReplaceNew:data OldFl:fl Animated:animate];
    }
}
-(NSNumber*)GetFL:(NSString*)word{
    char fl = getFirstChar(word);
    if(fl>='A'&&fl<='Z') fl += 32;
    return [NSNumber numberWithChar:fl];
}
-(NSInteger)GetSortePath:(NSNumber*)fl{
    //返回-1表示插入到最后
    NSInteger section = -1;
    
    if(_datas.count == 0) return section;
    
    if(_datas.count == 1){
        if(_datas[0]._fl.charValue < fl.charValue) return section;
        else return 0;
    }
    
    for(NSInteger s = 0 ; s < _datas.count -1; ++s ){
        //在两个中间
        if(_datas[s]._fl.charValue < fl.charValue && _datas[s+1]._fl.charValue > fl.charValue){
            return s+1;
        }
        if(_datas[s]._fl.charValue > fl.charValue){
            return s;
        }
    }
    
    return section;
}
-(NSInteger)GetFlPath:(NSNumber*)fl{
    NSInteger section = -1;
    for(NSInteger s = 0 ; s < _datas.count ; ++s){
        if([_datas[s]._fl isEqualToNumber:fl]) return s;
    }
    return section;
}
-(NSInteger)GetUserPath:(NSArray<ContactUserAbstract*>*)users UID:(NSString*)uid{
    NSInteger row = -1;
    for(NSInteger r = 0 ; r < users.count ; ++r){
        if([users[r].uid isEqualToString:uid]) return r;
    }
    return row;
}
-(NSIndexPath*)GetUserAbstractByUserIDAndFl:(NSNumber*)fl UID:(NSString*)uid{
    
    NSInteger section = [self GetFlPath:fl];
    if(section == -1) return nil;
    NSInteger row = [self GetUserPath:_datas[section]._datas UID:uid];
    if(row == -1) return nil;
    
    return [NSIndexPath indexPathForRow:row inSection:section];
    
}
-(void)InsertNew:(ContactUserAbstract*)userabstract Animated:(BOOL)animated{
    //这里肯定是新用户
    
    
    NSNumber* fl = [self GetFL:userabstract.nick];
    [_uids setObject:fl forKey:userabstract.uid];
    //是不是新的首字母
    NSInteger secindex  = [self GetFlPath:fl];
    
    //插入一条新的，这里需排序
    if(secindex == -1){
        
        FlMapData* flmapdata = [FlMapData new];
        flmapdata._fl = fl;
        flmapdata._datas = [NSMutableArray new];
        [flmapdata._datas addObject:userabstract];
        
        secindex = [self GetSortePath:fl];
        NSIndexPath* newsectionpath = nil;
        //尾部插入
        if(secindex == -1){
            newsectionpath = [NSIndexPath indexPathForRow:0 inSection:_datas.count+_sectionStart];
            [_datas addObject:flmapdata];
        }
        //中间插入
        else{
            newsectionpath = [NSIndexPath indexPathForRow:0 inSection:secindex+_sectionStart];
            [_datas insertObject:flmapdata atIndex:secindex];
        }
        
        if(animated){
            [_tableView beginUpdates];
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:newsectionpath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView insertRowsAtIndexPaths:@[newsectionpath] withRowAnimation:UITableViewRowAnimationAutomatic];
             [_tableView endUpdates];
        }
        
    }
    else{
        FlMapData* flmapdata = _datas[secindex];
        NSInteger rowindex = flmapdata._datas.count;
        [flmapdata._datas addObject:userabstract];
        NSIndexPath* newrowpath = [NSIndexPath indexPathForRow:rowindex inSection:secindex+_sectionStart];
        
        if(animated){
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[newrowpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView endUpdates];
        }
        
    }
}
-(void)ReplaceNew:(ContactUserAbstract*)userabstract OldFl:(NSNumber*)oldfl Animated:(BOOL)animated{
    
    
    //肯定有
    //是不是会替换首字母
    NSNumber* fl = [self GetFL:userabstract.nick];
    [_uids setObject:fl forKey:userabstract.uid];
    //不替换首字母，只更新
    if([oldfl isEqualToNumber:fl]){
        NSIndexPath* existindexpath = [self GetUserAbstractByUserIDAndFl:fl UID:userabstract.uid];
        assert(existindexpath);
        ContactUserAbstract* olduserasb = _datas[existindexpath.section]._datas[existindexpath.row];
        olduserasb.nick = userabstract.nick;
        olduserasb.avatar = userabstract.avatar;
        
        if(animated){
            
            [_tableView beginUpdates];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:existindexpath.row inSection:existindexpath.section+_sectionStart]] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView endUpdates];
        }
        
    }
    //替换首字母，移动row
    else{
        NSIndexPath* existindexpath = [self GetUserAbstractByUserIDAndFl:oldfl UID:userabstract.uid];
        assert(existindexpath);
        
        [_datas[existindexpath.section]._datas removeObjectAtIndex:existindexpath.row];
        
        
        if(_datas[existindexpath.section]._datas.count == 0){
            //删除section
            
            [_datas removeObjectAtIndex:existindexpath.section];
            if(animated){
                [_tableView beginUpdates];
                [_tableView deleteSections:[NSIndexSet indexSetWithIndex:existindexpath.section+_sectionStart] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_tableView endUpdates];
            }
        }
        //删除row
        else{
            
            if(animated){
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:existindexpath.row inSection:existindexpath.section+_sectionStart]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_tableView endUpdates];
            }
        }
        
        NSInteger secindex = [self GetFlPath:fl];
        //新section不存在
        if(secindex == -1) {
            FlMapData* flmapdata = [FlMapData new];
            flmapdata._fl = fl;
            flmapdata._datas = [NSMutableArray new];
            [flmapdata._datas addObject:userabstract];
            secindex = [self GetSortePath:fl];
            NSIndexPath* newindexpath = nil;
            
            //尾部插入
            if(secindex == -1) {
                
                newindexpath  = [NSIndexPath indexPathForRow:0 inSection:_datas.count+_sectionStart];
                [_datas addObject:flmapdata];
                
            }
            //中间插入
            else{
                
                newindexpath = [NSIndexPath indexPathForRow:0 inSection:secindex+_sectionStart];
                [_datas insertObject:flmapdata atIndex:secindex];
            }
            if(animated) {
                
                [_tableView beginUpdates];
                
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:newindexpath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_tableView insertRowsAtIndexPaths:@[newindexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_tableView endUpdates];
            }
        }
        //section存在插入新row
        else{
            FlMapData* flmapdata = _datas[secindex];
            NSInteger rowindex = flmapdata._datas.count;
            [flmapdata._datas addObject:userabstract];
            NSIndexPath* newrowpath = [NSIndexPath indexPathForRow:rowindex inSection:secindex+_sectionStart];
            if(animated){
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[newrowpath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_tableView endUpdates];
            }
        }
        
    }
    
}
//首字母个数
-(NSInteger)LetterCount{
    return [self Letters].count;
}
//所有首字母
-(NSArray<NSString*>*)Letters{
    
    NSMutableArray<NSString*>* ret = [NSMutableArray new];
    
    [_datas enumerateObjectsUsingBlock:^(FlMapData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:[[NSString stringWithFormat:@"%c",obj._fl.charValue] uppercaseString]];
    }];
    return ret;
}
-(ContactUserAbstract*)UserAbstractForIndexPath:(NSIndexPath*)indexpath{
    return _datas[indexpath.section-_sectionStart]._datas[indexpath.row];
}
-(NSString*)FLForSection:(NSInteger)section{
    return [NSString stringWithFormat:@"%c",_datas[section-_sectionStart]._fl.charValue];
}
-(NSArray*)UserAbstractsForSection:(NSInteger)section{
    return _datas[section-_sectionStart]._datas;
}
@end

