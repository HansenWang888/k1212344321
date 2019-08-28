//
//  ChatCell.h
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTimeDimCell.h"


extern   NSString* const SubNotify_AvatarTap;

@class  DDMessageEntity;


@interface ChatCell : ChatBaseCell

@end

@interface ChatTextCell : ChatCell

@end

@interface ChatTextCellRight : ChatTextCell

@end

@interface ChatImageCell : ChatCell

@end

@interface ChatImageRightCell : ChatImageCell

@end

@interface ChatVoiceCell : ChatCell

@end

@interface ChatVoiceRightCell : ChatVoiceCell

@end
@interface ChatUnknowLeftCell : ChatTextCell

@end
@interface ChatUnknowRightCell : ChatUnknowLeftCell

@end
