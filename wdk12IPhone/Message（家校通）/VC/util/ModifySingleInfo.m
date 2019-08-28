#import "ModifySingleInfo.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import <Masonry.h>
#import "ViewSetUniversal.h"
typedef void(^OnCompletion)(NSError* error);
typedef void(^DoneCallback)(NSString* value,OnCompletion block);

@interface ModifySingleInfo ()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, copy) NSString *sendText;
@property (assign, nonatomic) BOOL isTextView;

@property (nonatomic, strong) UILabel *limitLabel;

@end
#define LIMITNUM 16
@implementation ModifySingleInfo
{
    NSString* _objid;
    NSString* _defaultvalue;
    ModifySingleValueType _type;
    DoneCallback _donecallback;
}
-(id)initWithModifyType:(ModifySingleValueType) modifySingleValueType ObjectID:(NSString*)objid DefaultValue: (NSString*)defaultValue{
    
    self = [super init];
    _objid = objid;
    _defaultvalue = defaultValue;
    assert(_objid);
    _type = modifySingleValueType;
    self.sendText = defaultValue;
    
    switch (_type) {
        case ModifySingleValueTyperRmkname:
            [self initWithRMK];
            break;
        case ModifySingleValueTypeVerify:
            [self initWithVerify];
            break;
        case ModifySingleValueTypeGroupName:
            [self initWithGroupName];
            break;
        case ModifySingleValueTypeGroupMyNick:
            [self initWithGroupMyNick];
            break;
        default:
            break;
    }
    return self;
}
-(void)viewDidLoad{

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(OnDone)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isTextView ) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textFiled becomeFirstResponder];
    }
}
-(void)initWithGroupMyNick{
    self.title = IMLocalizedString(@"修改组内昵称", nil);
    self.textFiled.text = _defaultvalue;
    __block NSString* objid = _objid;
    _donecallback = ^(NSString* value,OnCompletion block){
        [[DDGroupModule instance]modifyGroupMyNick:objid MyNick:value Block:^(NSError * error, id respone) {
            block(error);
        }];
    };
}
-(void)initWithGroupName{
    self.title = IMLocalizedString(@"修改群组名称", nil);
    self.textFiled.text = _defaultvalue;
     __block NSString* objid = _objid;
    _donecallback = ^(NSString* value,OnCompletion block){
        [[DDGroupModule instance]modifyGroupName:objid GroupName:value Block:^(NSError * error, id respone) {
            block(error);
        }];
    };
}
-(void)initWithRMK{
    self.title = IMLocalizedString(@"修改备注", nil);
    self.textFiled.text = _defaultvalue;
    __block NSString* objid = _objid;
    _donecallback = ^(NSString* value,OnCompletion block){
        [[ContactModule shareInstance]modifyRmkname:objid Value:value Block:^(NSError *error) {
            block(error);
        }];
    };
}
-(void)initWithVerify{
    self.title = IMLocalizedString(@"发送好友验证", nil);
    self.isTextView = YES;
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    [ViewSetUniversal setView:self.textView borderWitdth:1 borderColor:[UIColor lightGrayColor]];
    __block NSString* objid = _objid;
    _donecallback = ^(NSString* value,OnCompletion block){
        [[ContactModule shareInstance]addFrindVerify:objid Verify:value Block:^(NSError * error) {
            block(error);
        }];
    };
}

-(void)OnDone{
    
    NSInteger length = 0;
    if (self.isTextView) {
        length = LIMITNUM;
    } else {
        length = 10;
    }
    if (self.sendText.length > length) {
        [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"内容太长了", nil)];
        return;
    } else if (self.sendText.length == 0) {
        [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"内容不能为空", nil)];
        return;
    }
    [self.view endEditing:YES];
    if(_donecallback && self.sendText ){
        _donecallback(self.sendText,^(NSError* error){
            if(!error){
                NSArray *vcs = self.navigationController.viewControllers;
                [self.navigationController popToViewController:vcs[0] animated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"操作失败", nil)];
                NSLog(@"error:%@,code:%ld",error.domain,error.code);
            }
        });
    }
}
- (void)setupSubView {
    if (self.isTextView) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14];
        label.text = IMLocalizedString(@"对方需要你填写验证信息", nil);
        label.textColor = [UIColor grayColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.view).offset(64);
        }];
        [self.view addSubview:self.textView];
        self.textView.text = _defaultvalue;
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(label.mas_bottom).offset(10);
            make.height.offset(200);
        }];
        [self.view addSubview:self.limitLabel];
        [self.limitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.textView).offset(-8);
        }];
        self.limitLabel.text = [NSString stringWithFormat:@"%02ld/%d",_defaultvalue.length,LIMITNUM];
    } else {
        [self.view addSubview:self.textFiled];
        [_textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(10);
            make.right.equalTo(self.view).offset(-10);
            make.top.equalTo(self.view).offset(84);
            make.height.offset(35);
        }];
//        UILabel *lable = [UILabel new];
//        [_textFiled addSubview:lable];
//        lable.text = @"1234";
//        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.right.offset(0);
//        }];
      
    }
}
- (void)textFiledValueChange {
    if (self.textFiled.text.length > 10) {
        self.textFiled.text = [self.textFiled.text substringWithRange:NSMakeRange(0, 10)];
    }
    self.sendText = _textFiled.text;
}
//MARK:textViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.limitLabel.textColor = [UIColor grayColor];
    if (textView.text.length > LIMITNUM) {
        self.textView.text = [self.textView.text substringWithRange:NSMakeRange(0, LIMITNUM)];
        self.limitLabel.text = [NSString stringWithFormat:@"%02ld/%d",textView.text.length,LIMITNUM];
    } else {
        self.limitLabel.text = [NSString stringWithFormat:@"%02ld/%d",textView.text.length,LIMITNUM];
        self.sendText = textView.text;
    }
}
- (UITextField *)textFiled {
    if (!_textFiled) {
        _textFiled = [UITextField new];
        [ViewSetUniversal setView:_textFiled cornerRadius:3];
        [ViewSetUniversal setView:_textFiled borderWitdth:1 borderColor:[UIColor lightGrayColor]];
        [_textFiled addTarget:self action:@selector(textFiledValueChange) forControlEvents:UIControlEventEditingChanged];
        _textFiled.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _textFiled;
}
- (UILabel *)limitLabel {
    if (!_limitLabel) {
        _limitLabel = [UILabel new];
        _limitLabel.textColor = [UIColor grayColor];
        _limitLabel.text = [NSString stringWithFormat:@"0/%d",LIMITNUM];;
        [_limitLabel sizeToFit];
    }
    return _limitLabel;
}
@end
