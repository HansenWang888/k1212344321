
#import <UIKit/UIKit.h>


@interface ContactUserAbstract : NSObject
-(id)initWithUserEntityAndContactInfoEntity:( DDUserEntity*) user
                          ContactInfoEntity:( ContactInfoEntity*) cinfo;
@property NSString* uid;
@property NSString* nick;
@property NSString* avatar;

-(NSComparisonResult)compare:(ContactUserAbstract*)other;
@end


@interface FlMapData : NSObject
@property NSNumber* _fl;
//uid->abs
@property NSMutableArray<ContactUserAbstract*>* _datas;
@end



@interface ContactDataModel : NSObject
-(id)initWithTableView:(UITableView*)tablview SectionStart:(NSInteger)sectionStart;
-(id)initWithTableView:(UITableView *)tablview SectionStart:(NSInteger)sectionStart Excludes:(NSArray<NSString*>*) uids;
-(void)reload;
-(NSArray*)excludes;
-(NSArray<NSString*>*)Letters;
-(NSInteger)LetterCount;
-(ContactUserAbstract*)UserAbstractForIndexPath:(NSIndexPath*)indexpath;
-(NSString*)FLForSection:(NSInteger)section;
-(NSArray*)UserAbstractsForSection:(NSInteger)section;
@end