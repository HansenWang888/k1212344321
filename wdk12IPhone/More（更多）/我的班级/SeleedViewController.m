//
//  SeleedViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/13.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "SeleedViewController.h"

@interface SeleedViewController ()
{
    NSInteger selectedNum;
}

@property (nonatomic,strong)NSArray * dataAry;

@end

@implementation SeleedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedNum = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beginMySelfWithData:(NSArray*)data
{
    self.dataAry = data;
    
    [self.myTableView reloadData];
}
#pragma mark tableViewDeleagte
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataAry.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary * dic = self.dataAry[indexPath.row];
    
    NSString * cellKey;
    if (self.type == 1) {
        //选择年级
        cellKey = @"dcsy";
    }else if (self.type == 2){
        //选择班级
        cellKey = @"bjmc";
    }
    
    if (self.type == 3) {
        [cell.textLabel setNumberOfLines:2];
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[dic objectForKey:@"km"],[dic objectForKey:@"nj"],[dic objectForKey:@"cb"],[dic objectForKey:@"jcbbmc"]];
    }else{
        cell.textLabel.text = [dic objectForKey:cellKey];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedNum = indexPath.row;
}

//背景
- (IBAction)clickTap:(id)sender {
    [self.view removeFromSuperview];
}

//取消按钮
- (IBAction)clickCancel:(id)sender {
    
    [self.view removeFromSuperview];
}

//确定
- (IBAction)clickCommit:(id)sender {
    
    if (selectedNum == -1) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"您还没有选择任何一项", nil)];
        return ;
    }
    
    [self.delegate selectedWithDic:self.dataAry[selectedNum] andType:self.type];
    [self.view removeFromSuperview];
}



@end
