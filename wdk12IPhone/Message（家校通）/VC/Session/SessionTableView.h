//
#import <UIKit/UIKit.h>

@class SessionCell;
@protocol SessionTableViewDelegta <NSObject>

@optional
-(void)SessionTouched:( SessionCell* _Nonnull)sessioncell;
-(void)SubscribeSectionTouched;
@end



typedef NS_ENUM(NSInteger,SessionTableViewType){
    SessionTableViewTypeSubscribe,
    SessionTableViewTypeUserAndGroupWithSubscribeEntry
};

@interface SessionTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

-(id)initWithSessionTableViewType:(SessionTableViewType)sessionTableViewType;
@property (nonatomic, weak, nullable) id <SessionTableViewDelegta> Sessiondelegate;
@end