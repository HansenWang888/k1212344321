//
//  HtmlStringVC.m
//  wdk12pad
//
//  Created by macapp on 16/3/14.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "HtmlStringVC.h"

@interface HtmlStringVC ()
@property (weak, nonatomic) IBOutlet UITextView *htmlStrView;

@end

@implementation HtmlStringVC{
    NSString* _htmlStr;
}
-(id)initWithHtmlStr:(NSString *)htmlStr{
    self = [super init];
    _htmlStr = htmlStr;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
