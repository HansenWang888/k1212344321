//
//  ChatRichtextCell.m
//  wdk12pad
//
//  Created by macapp on 16/2/20.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "ChatRichtextCell.h"
#import "DDMessageEntity.h"
#import "UIImageView+webcache.h"
#import "UIImage+FullScreen.h"
#import "ChatMarcos.h"

@interface RichTextHeader:UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
@implementation RichTextHeader

@end


@interface RichTextSubCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coveImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
@implementation RichTextSubCell



@end

@interface ChatRichtextCell()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@interface NSDictionary(SubscribeMaterial)
-(NSURL*)imageUrl;
@end
@implementation NSDictionary(SubscribeMaterial)

-(NSURL*)imageUrl{
    
    return [NSURL URLWithString:ImageFullUrl([self objectForKey:@"coverpic"])];
    
}

@end

@implementation ChatRichtextCell
{
    DDMessageEntity* _msgentity;
    NSDictionary*    _content;
    NSArray*         _subcontent;

    BOOL _reg;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [UIView new];
    _tableView.tableFooterView = [UIView new];
    
    _tableView.layer.cornerRadius = 10.0;
    _tableView.layer.masksToBounds = YES;
    _tableView.layer.borderWidth = 1.0;
    _tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tableView.rowHeight = RICH_TEXT_CELL_HEIGHT;
}
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    if(_msgentity == msgentity) return false;
    _msgentity = msgentity;
    _content = msgentity.info;
    _subcontent = [_content objectForKey:@"twsc"];
    [self makeHeader];
    [_tableView reloadData];
    return true;
}

-(void)makeHeader{
    RichTextHeader* header = [[[NSBundle mainBundle]loadNibNamed:@"RichTextHeader" owner:nil options:nil]objectAtIndex:0];
    [header.imageView sd_setImageWithURL:[_content imageUrl] placeholderImage:nil];
    header.userInteractionEnabled = NO;
    
//    header.timeLabel.text = [_content objectForKey:@"updatetime"] ;
    
    header.titleLabel.text = [_content objectForKey:@"title"];
    UIButton* headerp = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, RICH_TEXT_HEADER_HEIGHT)];
    [headerp addTarget:self action:@selector(headerSelect) forControlEvents:UIControlEventTouchUpInside];
    [headerp setBackgroundImage:[UIImage lightGrayImage] forState:UIControlStateHighlighted];
    [headerp setBackgroundImage:[UIImage whiteImage] forState:UIControlStateNormal];
    
    [headerp addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(headerp);
    }];
    _tableView.tableHeaderView = headerp;
}

-(void)headerSelect{
    NSString* matbody = [_content objectForKey:@"matbody"];
    if(matbody&&![matbody isEqualToString:@""]){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestHtmlString object:@{@"content":matbody,@"title":_content[@"title"]}];
        
        return;
    }
    
    NSString* hyperLink = [_content objectForKey:@"link"];
    if(hyperLink&& ![hyperLink isEqualToString:@""]){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReqeustHyperLink object:@[_msgentity.sessionId,hyperLink,_content[@"title"]]];
        
        return;
    }
}
#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return 0;
    return _subcontent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* CELL_ID = @"RichTextSubCell";
    if(!_reg){
        _reg = YES;
        UINib* nib = [UINib nibWithNibName:CELL_ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELL_ID];
    }
    RichTextSubCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
   
    cell.titleLabel.text = [_subcontent[indexPath.row] objectForKey:@"title"];
    [cell.coveImageView sd_setImageWithURL:[_subcontent[indexPath.row]  imageUrl]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* matbody = [_subcontent[indexPath.row] objectForKey:@"matbody"];
    if(matbody&&![matbody isEqualToString:@""]){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestHtmlString object:@{@"content":matbody,@"title":[_subcontent[indexPath.row] objectForKey:@"title"]}];
        
        return;
    }
    
    NSString* hyperLink = [_subcontent[indexPath.row] objectForKey:@"link"];
    
    if(hyperLink&& ![hyperLink isEqualToString:@""]){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReqeustHyperLink object:@[_msgentity.sessionId,hyperLink,[_subcontent[indexPath.row] objectForKey:@"title"]]];
    }
    
}
@end
