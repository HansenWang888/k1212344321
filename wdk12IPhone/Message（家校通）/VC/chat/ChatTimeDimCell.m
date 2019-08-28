//
//  ChatTimeDimCell.m
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ChatTimeDimCell.h"
#import "DDMessageEntity.h"
#import "NSDate+DDAddition.h"
@implementation ChatBaseCell
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    return YES;
}
-(void)setSessionEntity:(SessionEntity*)sentity{
    
}
-(void)setSessionID:(NSString*)sid{
    
}
-(void)setContentSize:(CGSize)size{
    
}
-(void)willAppare{
    
}
-(void)willDisappare{
    
}
@end

@interface ChatTimeDimCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@end



@implementation ChatTimeDimCell

-(void)setMessageEntity:(DDMessageEntity*)msgentity{
   
    _timeLable.text = [ [NSDate dateWithTimeIntervalSince1970:msgentity.msgTime] promptDateString];
}

- (void)awakeFromNib {
    // Initialization code
    
    _timeLable.layer.cornerRadius = 3.0;
    _timeLable.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
