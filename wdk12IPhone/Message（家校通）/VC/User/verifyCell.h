
#import <UIKit/UIKit.h>

@protocol VerifyCellDelegate <NSObject>

- (void)agreeAddition:(NSString *)verifyID;
- (void)refuseAddition:(NSString *)verifyID;
@end

@interface VerifyCell : UITableViewCell

@property (nonatomic, weak) id verifyDelegate;

-(NSString*)UserID;
-(void)setUidAndVerify:(NSString*)uid Verify:(NSString*)verify;

@end