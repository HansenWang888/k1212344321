//
//  SubscribeMenuBar.h
//  wdk12pad
//
//  Created by macapp on 16/2/19.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "borderdView.h"
@protocol SubscribeMenuDelegate
@required
-(void)onBack;
-(void)onMate:(NSDictionary*)mateDic;
@end

@interface SubscribeMenuBar : BorderedView

-(void)setSbid:(NSString*)sbid;
@property (nonatomic, weak, nullable) id <SubscribeMenuDelegate> delegate;
@end
