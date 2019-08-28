#import <Foundation/Foundation.h>

@class SessionEntity;
@class DDMessageEntity;


typedef void(^PullMessageCompetion)();
typedef void(^PullMessageWithTotalHeight)(CGFloat,NSInteger);
@interface MessageDataModel : NSObject

-(id)initWithSession:(SessionEntity*)sentity TableView:(UITableView*)tableView InitialMessageCount:(NSInteger)initialMessageCount PullMessageCount:(NSInteger)pullMessageCount;



-(NSInteger)count;
-(DDMessageEntity*)messageAtInde:(NSInteger)index;
-(CGSize)SizeForMessageAtIndex:(NSInteger)index;
-(void)insertNewMessage:(DDMessageEntity*)msgentity;

-(NSString*)chatPostfixWithIndex:(NSInteger)index;
-(NSString*)chatPrefixWithIndex:(NSInteger)index;
-(void)ScrollToBottomWithAnimate:(BOOL)animate;

-(void)setAutoToButton:(BOOL)enable;

-(BOOL)canPulling;
-(void)pullMessage:(PullMessageWithTotalHeight)block;
//private api
//-(void)getSessionMessage:(NSInteger)count Time:(NSTimeInterval)time Block:(PullMessageCompeletion)block;

-(BOOL)isVoicing;
-(void)addBlinkAudioPlacehoder;
-(void)UpdateOrReplaceVoiceMessage:(DDMessageEntity*)msgentity;


@end