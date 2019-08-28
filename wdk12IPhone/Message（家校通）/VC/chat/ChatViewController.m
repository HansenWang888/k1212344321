#import "AVFoundation/AVFoundation.h"
#import "ChatViewController.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "DDUserModule.h"
#import "DDDatabaseUtil.h"
#import "DDGroupModule.h"
#import "GroupEntity.h"
#import "contactmodule.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import "borderdView.h"
#import "MessageDataModel.h"
#import "MessageSendModule.h"
#import "ChatCell.h"
#import "ChatTimeDimCell.h"
#import "SDWebImageManager.h"
#import "SVProgressHUD.h"
#import "UserInfoViewController.h"
#import "SessionDetailViewController.h"
#import "SubscribeInfoController.h"
#import "SubscribeMenuBar.h"
#import "HyperLinkVC.h"
#import "ResourceVCViewController.h"
#import "HtmlStringVC.h"
#import "ChatGroupAddView.h"

#import "IMChatPhotoView.h"
#import "IMPhotoModel.h"
#import "ChatRecordPromtView.h"
#import "nameLabel.h"
#import <TZImagePickerController.h>
#import "IMMP3Recorder.h"

#define NUM_CELL _dataModel.count

#define MADJ_LOG(msg) NSLog(@"%@,%s,%d",msg,__FUNCTION__,__LINE__)

static const int PULL_IDLE = 1;
static const int PULL_ING  = 2;

static const int BTN_DOW = 1;
static const int BTN_UP  = 2;
static const NSInteger TOUCH_CANCEL= UIControlEventTouchCancel|UIControlEventTouchDragOutside|UIControlEventTouchUpOutside;

@interface ChatViewController()<TZImagePickerControllerDelegate,ChatPhotoViewDelegate,ChatGroupAddDelegate,MP3RecorderDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;
@property (weak, nonatomic) IBOutlet UITextView *inputText;

@property (weak, nonatomic) IBOutlet UIButton *inputAudio;

@property (weak, nonatomic) IBOutlet BorderedView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightCS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomCS;

@property (weak, nonatomic) IBOutlet UIButton *otherPlusButton;
//@property (weak, nonatomic) IBOutlet BorderedView *otherBar;
//@property (weak, nonatomic) IBOutlet UIButton *camera;
//@property (weak, nonatomic) IBOutlet UIButton *photos;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AudioLeftCons;
@property (nonatomic, strong) NameLabel *titleLabel;
@property (nonatomic, strong) ChatGroupAddView *addGroupV;
@property (nonatomic, strong) IMChatPhotoView *photoView;

@property (nonatomic, strong) ChatRecordPromtView *recordPromtView;

@end

@implementation ChatViewController
{
    SessionEntity* _sentity;
    BOOL _reg;
    MessageDataModel*      _dataModel;
    
    int pullstate;
    UIImagePickerController* _imagePicker;
    
    BOOL _keyboardHideByOtherBar;
    
    UIActivityIndicatorView* _indicator;
    
    MASConstraint* _indicatorCS;
    
    dispatch_queue_t _audioQueue;
    
    int _audioBtnState;
    
    SubscribeMenuBar* _menuBar;
    BOOL              _appear;
}

+(id)initWithSessionEntity:(SessionEntity*)sentity{
    ChatViewController* ret = [[ChatViewController alloc]init];
    [ret setSession:sentity];
    
    return ret;
}
+(nullable id)initWithUserID:(NSString*)uid{
    ChatViewController* ret = [[ChatViewController alloc]init];
    SessionEntity* sentity = [[SessionModule sharedInstance]GetOrCreateSessionEntityWithUserID:uid];
    
    [ret setSession:sentity];
    return ret;
}
+(nullable id)initWithGroupID:(NSString*)gid{
    ChatViewController* ret = [[ChatViewController alloc]init];
    SessionEntity* sentity = [[SessionModule sharedInstance]GetOrCreateSessionEntityWithGroupID:gid];
    [ret setSession:sentity];
    return ret;
}
+(id)initWithSubscribeID:(NSString*)sbid{
    ChatViewController* ret = [[ChatViewController alloc]init];
    SessionEntity* sentity = [[SessionModule sharedInstance]GetOrCreateSessionEntityWithSBID:sbid];
    [ret setSession:sentity];
    return ret;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _appear = YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    
    _appear = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputText endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHidesBottomBarWhenPushed:YES];
    [self.view addSubview:self.recordPromtView];
    self.navigationItem.titleView = self.titleLabel;
    self.titleLabel.text = IMLocalizedString(@"会话", nil);
    [self.recordPromtView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.offset(150);
    }];
    self.recordPromtView.hidden = YES;
}

-(id)init{
    self = [super init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [_titleBtn setTitleColor:COLOR_Creat(102, 102, 102, 1) forState:UIControlStateNormal];
    //    [_titleBtn setTitle:@"会话" forState:UIControlStateNormal];
    //    _titleBtn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:16];
    //    [_titleBtn addTarget:self action:@selector(titleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self awakeFromNib];
    [self.otherPlusButton setTitle:@"\U0000e67b" forState:UIControlStateNormal];
    [self.otherPlusButton setTitle:@"\U0000e67f" forState:UIControlStateSelected];
    [self.keyboardButton setTitle:@"\U0000e67c" forState:UIControlStateNormal];
    [self.audioButton setTitle:@"\U0000e67a" forState:UIControlStateNormal];
    
    _reg = NO;
    
    pullstate = PULL_IDLE;
    
    _imagePicker =    [[UIImagePickerController alloc]init];
    _imagePicker.delegate = self;
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        //防止摄像头不可使用而崩溃
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    //    [RecorderManager sharedManager].delegate = self;
    [IMMP3Recorder shareInstance].delegate = self;
    
    _audioQueue = dispatch_queue_create("cn.12study.audioqueue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onAvatap:) name:SubNotify_AvatarTap object:nil];
    [self.inputAudio setTitle:IMLocalizedString(@"按下开始说话", nil) forState:UIControlStateNormal];
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [_inputAudio addTarget:self action:@selector(onAudioStart) forControlEvents:UIControlEventTouchDown];
    [_inputAudio addTarget:self action:@selector(onAudioCancel) forControlEvents:TOUCH_CANCEL];
    [_inputAudio addTarget:self action:@selector(onAudioAccept) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [_audioButton addTarget:self action:@selector(onFocus:) forControlEvents:UIControlEventTouchDown];
    [_audioButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpOutside];
    [_audioButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpInside];
    [_otherPlusButton addTarget:self action:@selector(onFocus:) forControlEvents:UIControlEventTouchDown];
    [_otherPlusButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpOutside];
    [_otherPlusButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_keyboardButton addTarget:self action:@selector(onFocus:) forControlEvents:UIControlEventTouchDown];
    [_keyboardButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpOutside];
    [_keyboardButton addTarget:self action:@selector(LossFocus:) forControlEvents:UIControlEventTouchUpInside];
    
    [_audioButton addTarget:self action:@selector(onAudioClick) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardButton addTarget:self action:@selector(onKeyBoardClick) forControlEvents:UIControlEventTouchUpInside];
    [_otherPlusButton addTarget:self action:@selector(onOtherClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _audioButton.layer.masksToBounds = YES;
    _audioButton.layer.cornerRadius = _audioButton.frame.size.width/2.0;
    
    _otherPlusButton.layer.masksToBounds = YES;
    _otherPlusButton.layer.cornerRadius = _otherPlusButton.frame.size.width/2.0;
    
    
    _keyboardButton.layer.masksToBounds = YES;
    _keyboardButton.layer.cornerRadius = _keyboardButton.frame.size.width/2.0;
    
    _inputText.layer.borderColor  = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    _inputText.layer.borderWidth = 0.5;
    _inputText.layer.cornerRadius = 5.0;
    _inputText.layer.masksToBounds = YES;
    _inputAudio.layer.borderColor  = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    _inputAudio.layer.borderWidth = 0.5;
    _inputAudio.layer.cornerRadius = 5.0;
    _inputAudio.layer.masksToBounds = YES;
    
    
    
    _tableView.backgroundView = [[UIView alloc]init];
    _tableView.backgroundView.backgroundColor = [UIColor whiteColor];
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_tableView.backgroundView addSubview:_indicator];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_tableView.backgroundView.mas_centerX);
        _indicatorCS = make.bottom.equalTo(_tableView.backgroundView.mas_top);
    }];
    [_indicator stopAnimating];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onHyperLink:) name:DDNotificationReqeustHyperLink object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOpenFile:) name:DDNotificationRequestOpenFile object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onHtmlString:) name:DDNotificationRequestHtmlString object:nil];
    [_inputText addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [_tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionPrior context:nil];
}
//- (void)titleBtnClick {
//    if (self.titleBtn.selected) {
//        [UIView animateWithDuration:ANIMATION_TIME animations:^{
//            self.addGroupV.alpha = 0;
//        }];
//        self.titleBtn.selected = NO;
//        return;
//    }
//    self.titleBtn.selected = !self.titleBtn.selected;
//    [self addGroupV];
//    [UIView animateWithDuration:ANIMATION_TIME animations:^{
//        _addGroupV.alpha = 1.0;
//    }];
//    //MARK:addView friends
//}
-(void)onAvatap:(NSNotification*)notify{
    
    NSString* uid = notify.object;
    UserInfoViewController* vc = [[UserInfoViewController alloc]init];
    vc.isContactVC = NO;
    [vc setUserID:uid];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)indiactorRePos{
    CGFloat top = -_tableView.contentOffset.y;
    //    _indicatorCS.constant = top;
    if (_indicator) {
        _indicatorCS.offset(top);
    }
    
}


-(void)keyBoardWillShow:(NSNotification*)nofify{
    self.photoView.hidden = YES;
    if (self.otherPlusButton.selected) {
        
        self.otherPlusButton.selected = !self.otherPlusButton.selected;
    }
    NSDictionary*info=[nofify userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        _bottomBarBottomCS.constant = -kbSize.height;
        [self.view layoutIfNeeded];
        
        [_dataModel ScrollToBottomWithAnimate:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}
-(void)keyBoardWillHide:(NSNotification*)nofify{
    if(_keyboardHideByOtherBar) return;
    self.photoView.hidden = YES;
    if (self.otherPlusButton.selected) {
        self.otherPlusButton.selected = !self.otherPlusButton.selected;
    }
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        
        _bottomBarBottomCS.constant = 0;
        [self.view layoutIfNeeded];
        [_dataModel ScrollToBottomWithAnimate:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(object == _inputText){
        CGFloat height = _inputText.contentSize.height +16;
        if(height<49) height = 49;
        if(height != _bottomBarHeightCS.constant){
            
            [UIView animateWithDuration:0.25 animations:^{
                _bottomBarHeightCS.constant = height;
                
                
                [_bottomBar  layoutIfNeeded];
                [self.view layoutIfNeeded];
                [_dataModel ScrollToBottomWithAnimate: NO];
            } completion:^(BOOL finished) {
                [_bottomBar setNeedsDisplay];
            }];
            
        }
    }
    else{
        [self handleTableViewContentChange:change];
    }
}
-(void)onFocus:(id)sender{
    [sender setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
}
-(void)LossFocus:(id)sender{
    if(sender != _inputAudio){
        [sender setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [sender setBackgroundColor:[UIColor whiteColor]];
    }
}
typedef void(^checkAudioBlock)(BOOL);
-(void)checkAudio:(void(^)(BOOL))block{
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (available) {
                //completionHandler
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:IMLocalizedString(@"无法录音", nil) message:IMLocalizedString(@"请在“设置-隐私-麦克风”选项中允许访问你的麦克风", nil) delegate:nil cancelButtonTitle:IMLocalizedString(@"确定", nil) otherButtonTitles:nil] show];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(available);
            });
            
        }];
        
    }
}
-(void)onAudioStart{
    _audioBtnState = BTN_DOW;
    [self.recordPromtView showView];
    [self onFocus:_inputAudio];
    if(![_dataModel isVoicing]){
        
        [self checkAudio:^(BOOL enable) {
            if(enable && _audioBtnState == BTN_DOW){
                [_dataModel addBlinkAudioPlacehoder];
                dispatch_async(_audioQueue, ^{
                    
                    //                    [[RecorderManager sharedManager]startRecording];
                    [[IMMP3Recorder shareInstance] start];
                });
            }
            else{
                [self LossFocus:_inputAudio];
                MADJ_LOG(@"隐私,或终端");
            }
        }];
    }
}
-(void)onAudioAccept{
    _audioBtnState = BTN_UP;
    [self.recordPromtView hiddenView];
    [self LossFocus:_inputAudio];
    if([_dataModel isVoicing]){
        //    NSLog(@"完成录音");
        dispatch_async(_audioQueue, ^{
            //            [[RecorderManager sharedManager]stopRecording];
            [[IMMP3Recorder shareInstance] stop];
        });
        
        //    NSLog(@"完成1录音");
    }
}
-(void)onAudioCancel{
    _audioBtnState = BTN_UP;
    [self.recordPromtView hiddenView];
    [self LossFocus:_inputAudio];
    if([_dataModel isVoicing]){
        //   NSLog(@"取消录音");
        dispatch_async(_audioQueue, ^{
            //            [[RecorderManager sharedManager]cancelRecording];
            [[IMMP3Recorder shareInstance] forceStop];
        });
        [_dataModel UpdateOrReplaceVoiceMessage:nil];
    }
    
}
-(void)onAudioClick{
    if([_inputText resignFirstResponder]){
        //        _inputText.text = nil;
    }
    _inputAudio.hidden = NO;
    _inputText.hidden = YES;
    _audioButton.hidden = YES;
    _keyboardButton.hidden = NO;
    if(self.photoView.hidden == NO){
        [self.view layoutIfNeeded];
        [self onOtherClick];
        [UIView animateWithDuration:0.25 animations:^{
            _bottomBarBottomCS.constant = 0.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            _photoView.hidden = YES;
        }];
    }
}
-(void)onKeyBoardClick{
    _audioButton.hidden = NO;
    _keyboardButton.hidden = YES;
    _inputText.hidden = NO;
    _inputAudio.hidden = YES;
    if([_inputText becomeFirstResponder]){
        //        _inputText.text = nil;
    }
}

-(void)onOtherClick{
    
    self.otherPlusButton.selected = !self.otherPlusButton.selected;
    if(self.photoView.hidden == YES){
        _keyboardHideByOtherBar = YES;
        [_inputText resignFirstResponder];
        _photoView.hidden = NO;
        _keyboardButton.hidden = YES;
        _audioButton.hidden = NO;
        _inputAudio.hidden = YES;
        _inputText.hidden = NO;
        //        _inputText.text = @"";
        //显示
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            _bottomBarBottomCS.constant = -230;
            [self.view layoutIfNeeded];
            [_dataModel ScrollToBottomWithAnimate: NO];
        } completion:^(BOOL finished) {
            _keyboardHideByOtherBar = NO;
        }];
    }
    else{
        //隐藏
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            _bottomBarBottomCS.constant = 0;
            [self.view layoutIfNeeded];
            [_dataModel ScrollToBottomWithAnimate: NO];
        } completion:^(BOOL finished) {
            _photoView.hidden = YES;
        }];
        
        
    }
}

-(void)onCameraClick{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:_imagePicker animated:YES completion:^{
            
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMLocalizedString(@"设置", nil) message:IMLocalizedString(@"相机未打开", nil) delegate:nil cancelButtonTitle:IMLocalizedString(@"知道了", nil) otherButtonTitles:nil] ;
        [alert show];
    }
}

-(void)createMenubar{
    _menuBar = [[SubscribeMenuBar alloc]init];
    [self.view addSubview:_menuBar];
    [_menuBar setSbid:_sentity.sessionID];
    _menuBar.backgroundColor = [UIColor whiteColor];
    [_menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self.view);
        make.height.offset(49);
    }];
    _menuBar.hidden = YES;
    _menuBar.delegate = self;
}
-(void)onMenu{
    [self.inputText endEditing:YES];
    _menuBar.hidden = NO;
}
-(void)setSession:(SessionEntity *)sentity{
    assert(_sentity == nil);
    
    _sentity = sentity;
    if(sentity.sessionType == SessionTypeSessionTypeSingle){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userUpdate:) name:DDNotificationUserUpdated object:nil];
        [self userUpdateImpl:_sentity.sessionID];
        
        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
        rightButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:25];
        [rightButton setTitle:@"\U0000e657" forState:UIControlStateNormal];
        //        [rightButton setTitleColor:COLOR_Creat(94, 191, 109, 1) forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onRightItemClick)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
        
        self.navigationItem.rightBarButtonItem= rightItem;
        
        [[ContactModule shareInstance]getUserInfoWithNotification:sentity.sessionID ForUpdate:YES];
        
        //        self.titleBtn.enabled = YES;
    }
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(groupUpdate:) name:DDNotificationGroupUpdated object:nil];
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:_sentity.sessionID Forupdate:YES];
        
        [self groupUpdateImpl:_sentity.sessionID];
        
        //        self.titleBtn.enabled = YES;
        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
        rightButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:25];
        [rightButton setTitle:@"\U0000e656" forState:UIControlStateNormal];
        //        [rightButton setTitleColor:COLOR_Creat(94, 191, 109, 1) forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onRightItemClick)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
        
        self.navigationItem.rightBarButtonItem= rightItem;
        
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:sentity.sessionID Forupdate:YES];
    }
    if(sentity.sessionType == SessionTypeSessionTypeSubscription){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
        rightButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:25];
        [rightButton setTitle:@"\U0000e61a" forState:UIControlStateNormal];
        //        [rightButton setTitleColor:COLOR_Creat(94, 191, 109, 1) forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onRightItemClick)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
        
        self.navigationItem.rightBarButtonItem= rightItem;
        
        _AudioLeftCons.constant = 45;
        //        self.titleBtn.enabled = NO;
        UIButton* menuBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 33, 33)];
        [_bottomBar addSubview:menuBtn];
        [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(_bottomBar).offset(8);
            make.width.height.offset(33);
        }];
        
        [menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        menuBtn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:25];
        [menuBtn setTitle:@"\U0000E673" forState:UIControlStateNormal];
        
        [menuBtn addTarget:self action:@selector(onMenu) forControlEvents:UIControlEventTouchUpInside];
        [self subscribeUpdateImpl:_sentity.sessionID];
        [self createMenubar];
        
        [[SubscribeModule shareInstance]getSBInfoWithNotification:_sentity.sessionID ForUpdate:YES];
    }
    _dataModel = [[MessageDataModel alloc]initWithSession:sentity TableView:_tableView InitialMessageCount:20 PullMessageCount:20];
    
    [[SessionModule sharedInstance]setSessionOpened:sentity.sessionID Opened:YES];
    [[SessionModule sharedInstance]setSessionRead:sentity   ];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSessionUpdate:) name:DDNotificationSessionUpdated object:nil];
}
-(void)onSessionUpdate:(NSNotification*)notify{
    if(notify.object == _sentity){
        [_tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatBaseCell* cell = (ChatBaseCell*)obj;
            [cell setSessionEntity:notify.object];
        }];
    }
}
-(void)onRightItemClick{
    if(_sentity.sessionType == SessionTypeSessionTypeGroup){
        SessionDetailViewController* vc = [[SessionDetailViewController alloc]initWithSession:_sentity];
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if (_sentity.sessionType == SessionTypeSessionTypeSingle) {
        
        UserInfoViewController* vc = [[UserInfoViewController alloc]init];
        vc.isContactVC = NO;
        [vc setUserID:_sentity.sessionID];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        SubscribeInfoController* vc = [[SubscribeInfoController alloc]initWithSBID:_sentity.sessionID];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)userUpdate:(NSNotification*)notify{
    NSString* uid = notify.object;
    if([uid isEqualToString:_sentity.sessionID]){
        [self userUpdateImpl:uid];
    }
}
-(void)userUpdateImpl:(NSString*) uid{
    DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:uid];
    ContactInfoEntity* centity = [[ContactModule shareInstance]GetContactInfoByID:uid];
    NSString* text = nil;
    if(uentity){
        text = uentity.nick;
    }
    if(centity && [centity hasRmkname]){
        text = centity.rmkname;
    }
    //    self.navTitle = text
    [self.titleLabel setUid:uid];
    //    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@",text] forState:UIControlStateNormal];
    
}
-(void)groupUpdate:(NSNotification*)notify{
    NSString* gid = [notify.object objectAtIndex:0];
    GroupNotifyType type = [[notify.object objectAtIndex:1] integerValue];
    if(type & GROUP_NOTIFY_MEMBER && [gid isEqualToString:_sentity.sessionID]){
        [self groupUpdateImpl:gid];
    }
}
-(void)groupUpdateImpl:(NSString*)gid{
    GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:gid];
    if(!gentity) return;
    //    self.navTitle = [NSString stringWithFormat:@"会话(%ld)",gentity.groupUserIds.count];
    [self.titleLabel setGid:gid];
    //    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",gentity.name,gentity.groupUserIds.count] forState:UIControlStateNormal];
    
    __block BOOL ingroup = NO;
    
    [gentity.groupUserIds enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isEqualToString:TheRuntime.user.objID]){
            ingroup = YES;
            *stop = YES;
        }
    }];
    if(!ingroup){
        self.navigationItem.rightBarButtonItem = nil;
    }
}
-(void)subscribeUpdate:(NSNotification*)notify{
    NSString* sbuuid = notify.object[0];
    if(![_sentity.sessionID isEqualToString:sbuuid]) return;
    SubscribeUpdateType type = [notify.object[1] integerValue];
    
    if(type != SubscribeUpdateTypeInfo) return;
    [self subscribeUpdateImpl:sbuuid];
}
-(void)subscribeUpdateImpl:(NSString*)sbid{
    SubscribeEntity* sbentity = [[SubscribeModule shareInstance]getSubscribeBySBID:sbid];
    if(sbentity){
        //        self.navTitle = sbentity.name;
        //        [self.titleBtn setTitle:sbentity.name forState:UIControlStateNormal];
        [self .titleLabel setSBID:sbid];
    }
}
-(void)onHyperLink:(NSNotification*)notify{
    NSString* sid = notify.object[0];
    if(![sid isEqualToString:_sentity.sessionID]) return;
    if(_appear == NO) return;
    NSString* hyperlink = notify.object[1];
    NSString* title     = notify.object[2];
    HyperLinkVC* vc = [[HyperLinkVC alloc]initWithHyperLink:hyperlink AndTitle:title];
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)onOpenFile:(NSNotification*)notify {
    if(_appear == NO) return;
    NSString* filename = notify.object[0];
    NSString* fileurl = notify.object[1];
    NSString* filetransurl = notify.object[2];
    NSString* ext = notify.object[3];
    ResourceVCViewController* vc = [[ResourceVCViewController alloc]initWithPath:fileurl ConverPath:filetransurl Type:ext Name:filename];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)onHtmlString:(NSNotification*)notify{
    if(_appear == NO) return;
    NSString* htmlstr = notify.object[@"content"];
    HyperLinkVC* vc = [[HyperLinkVC alloc]initWithHtmlStr:htmlstr];
    vc.title = notify.object[@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark menu delegate
-(void)onBack{
    _menuBar.hidden = YES;
}
-(void)onMate:(NSDictionary *)mateDic{
    
    [[MessageSendModule shareInstance]makeSubscribeMessage:mateDic Session:_sentity Block:^(DDMessageEntity *msgentity) {
        
        
        if(msgentity) [_dataModel insertNewMessage:msgentity];
    }];
}
#pragma mark delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataModel.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatBaseCell* basecell = (ChatBaseCell *)cell;
    cell.backgroundColor = [UIColor clearColor];
    DDMessageEntity* msgentity = [_dataModel messageAtInde:indexPath.row];
    
    [basecell setSessionEntity:_sentity];
    [basecell setMessageEntity:msgentity];
    
    [basecell setContentSize:[_dataModel SizeForMessageAtIndex:indexPath.row]];
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0){
    ChatBaseCell* basecell = (ChatBaseCell *)cell;
    [basecell willDisappare];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* prefix = [_dataModel chatPrefixWithIndex:indexPath.row];
    NSString* postfix = [_dataModel chatPostfixWithIndex:indexPath.row];
    
    
    NSString* CELL_ID = [NSString stringWithFormat:@"%@_%@",prefix,postfix];
    if(!_reg){
        
        UINib* nib = nil;
        nib = [UINib nibWithNibName:@"Text_right" bundle:nil];
        
        [tableView registerNib:nib forCellReuseIdentifier:@"Text_right"];
        
        nib = [UINib nibWithNibName:@"Text_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Text_left"];
        nib = [UINib nibWithNibName:@"Voice_right" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Voice_right"];
        nib = [UINib nibWithNibName:@"Voice_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Voice_left"];
        nib = [UINib nibWithNibName:@"Image_right" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Image_right"];
        nib = [UINib nibWithNibName:@"Image_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Image_left"];
        nib = [UINib nibWithNibName:@"Video_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Video_left"];
        nib = [UINib nibWithNibName:@"File_left" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"File_left"];
        nib = [UINib nibWithNibName:@"File_right" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"File_right"];
        nib = [UINib nibWithNibName:@"Time_center" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Time_center"];
        nib = [UINib nibWithNibName:@"RichText_center" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"RichText_center"];
        
        [tableView registerNib:[UINib nibWithNibName:@"Invite_left" bundle:nil] forCellReuseIdentifier:@"Invite_left"];
        [tableView registerNib:[UINib nibWithNibName:@"Invite_right" bundle:nil] forCellReuseIdentifier:@"Invite_right"];
        [tableView registerNib:[UINib nibWithNibName:@"Other_right" bundle:nil] forCellReuseIdentifier:@"Other_right"];
        [tableView registerNib:[UINib nibWithNibName:@"Other_left" bundle:nil] forCellReuseIdentifier:@"Other_left"];
        [tableView registerNib:[UINib nibWithNibName:@"IMChatshareLeftCell" bundle:nil] forCellReuseIdentifier:@"Share_left"];
        [tableView registerNib:[UINib nibWithNibName:@"IMChatshareRightCell" bundle:nil] forCellReuseIdentifier:@"Share_right"];
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [_dataModel SizeForMessageAtIndex:indexPath.row].height;
    
    return height;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){
        if(textView.text.length > 0 ){
            DDMessageEntity* msgentity = [[MessageSendModule shareInstance]sendTextMessage:textView.text Session:_sentity];
            
            if(msgentity) [_dataModel insertNewMessage:msgentity];
            else [SVProgressHUD showInfoWithStatus:IMLocalizedString(@"不能发送空白的消息", nil)];
        }
        
        _inputText.text = nil;
        
        return NO;
    }
    
    return YES;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if(scrollView == _tableView && [_inputText resignFirstResponder]){
////        _inputText.text = nil;
//        return;
//    }
//    if(scrollView == _tableView && _bottomBar.hidden == NO){
//        [self.view layoutIfNeeded];
//        [UIView animateWithDuration:0.25 animations:^{
//            _bottomBarBottomCS.constant = 0;
//            [self.view layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            _photoView.hidden = YES;
//        }];
//    }
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(scrollView.contentOffset.y< -104 && pullstate == PULL_IDLE && _indicator.isAnimating == NO && [_dataModel canPulling]){
//        [_indicator startAnimating];
//    }
//
//    if(scrollView.contentOffset.y < -104 && scrollView.isTracking == NO
//       && pullstate == PULL_IDLE && [_dataModel canPulling]){
//        pullstate = PULL_ING;
//        //_tableView.userInteractionEnabled = NO;
//
//        [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
//            [scrollView setContentOffset:CGPointMake(0, -104) animated:NO ];
//            _indicatorCS.offset(104);
////            _indicatorCS.constant = 104;
//            [_tableView.backgroundView layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            CGFloat height = scrollView.contentOffset.y;
//
//            [_dataModel pullMessage:^(CGFloat msgheight,NSInteger dim) {
//                if(dim == 0){
//                    [_indicator stopAnimating];
//                    _tableView.userInteractionEnabled = YES;
//                    return ;
//                }
//                CGFloat nheight = height+msgheight;
//
//
//                [scrollView setContentOffset:CGPointMake(0, nheight) animated:NO];
//
//            }];
//        }];
//
//
//    }
//    else{
//        [self indiactorRePos];
//    }
//
//    if(scrollView.contentOffset.y <= -scrollView.contentInset.top){
//        [_dataModel setAutoToButton:NO];
//    }
//    if(scrollView.contentOffset.y >= scrollView.contentSize.height-scrollView.frame.size.height){
//        [_dataModel setAutoToButton:YES];
//    }
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.inputText.isFirstResponder && abs((int)scrollView.contentOffset.y) > 30) {
        [self.inputText endEditing:YES];
    }
}

-(void)handleTableViewContentChange:(NSDictionary*)dic{
    if(pullstate == PULL_ING){
        _tableView.userInteractionEnabled = YES;
        [_indicator stopAnimating];
        pullstate = PULL_IDLE;
        
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
    NSLog(@"1");
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        NSURL* url = [info objectForKey:UIImagePickerControllerReferenceURL];
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if(!image || ! url) return;
        
        [[MessageSendModule shareInstance]sendImageMessageWithUrl:image Url:url Session:_sentity Block:^(DDMessageEntity *msgentity) {
            if(msgentity) [_dataModel insertNewMessage:msgentity];
        }];
        
    }
    else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [[MessageSendModule shareInstance]sendImageMessage:image  Session:_sentity Block:^(DDMessageEntity *msgentity) {
            if(msgentity) [_dataModel insertNewMessage:msgentity];
        }];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark audio

- (void)didFinished:(NSString *)filePath Interval:(NSTimeInterval)interval {
    
    if(interval > 1.5){
        [[MessageSendModule shareInstance]sendVoiceWithFilePath:filePath Length:interval Session:_sentity  Block:^(DDMessageEntity *msgentity) {
            MADJ_LOG(@"结束录音");
            if(msgentity) [_dataModel UpdateOrReplaceVoiceMessage:msgentity];
        }];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_dataModel UpdateOrReplaceVoiceMessage:nil];
            MADJ_LOG(@"结束录音,太短了");
            [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"时间太短", nil)];
        });
    }
}
- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval{
    if(interval > 1.5){
        [[MessageSendModule shareInstance]sendVoiceWithFilePath:filePath Length:interval Session:_sentity  Block:^(DDMessageEntity *msgentity) {
            MADJ_LOG(@"结束录音");
            if(msgentity) [_dataModel UpdateOrReplaceVoiceMessage:msgentity];
        }];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_dataModel UpdateOrReplaceVoiceMessage:nil];
            MADJ_LOG(@"结束录音,太短了");
            [SVProgressHUD showErrorWithStatus:IMLocalizedString(@"时间太短", nil)];
        });
    }
}
- (void)recordingTimeout{
    NSLog(@"%s",__FUNCTION__);
}
- (void)recordingStopped{
    NSLog(@"%s",__FUNCTION__);
}
- (void)recordingFailed:(NSString *)failureInfoString{
    NSLog(@"%s",__FUNCTION__);
}
//MARK:ChatGroupAddDelegate
- (void)chatGroupInfoUserWithVC:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)chatGroupAddUserWithVC:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)chatGroupDeleUserWithVC:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}
- (ChatGroupAddView *)addGroupV {
    if (!_addGroupV) {
        UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        _addGroupV = [[ChatGroupAddView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        [self.view addSubview:_addGroupV];
        [_addGroupV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(64);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@104);
        }];
        _addGroupV.sentity = _sentity;
        _addGroupV.alpha = 0;
        _addGroupV.addDelegate = self;
    }
    return _addGroupV;
}
#pragma mark image
- (IMChatPhotoView *)photoView {
    if (!_photoView) {
        _photoView = [IMChatPhotoView chatPhotoView];
        [self.view addSubview:_photoView];
        [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_bottomBar);
            make.top.mas_equalTo(_bottomBar.mas_bottom);
            make.height.offset(230);
        }];
        _photoView.delegate = self;
        _photoView.hidden = YES;
        
    }
    return _photoView;
}
-(void)showAlbum:(id)sender{
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:5 delegate:self];
    vc.isSelectOriginalPhoto = YES;
    vc.allowPickingVideo = NO;
    vc.autoDismiss = YES;
    [self presentViewController:vc animated:1 completion:nil];
    //    LSYAlbumCatalog *albumCatalog = [[LSYAlbumCatalog alloc] init];
    //    albumCatalog.delegate = self;
    //    albumCatalog.maximumNumberOfSelectionMedia = 5;
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumCatalog];
    //    [self presentViewController:nav animated:YES completion:nil];
}
-(void)showCamera:(id)sender{
    //相机
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
        [self presentViewController:_imagePicker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMLocalizedString(@"设置", nil) message:IMLocalizedString(@"相机未打开", nil) delegate:nil cancelButtonTitle:IMLocalizedString(@"知道了", nil) otherButtonTitles:nil] ;
        [alert show];
    }
    
}
-(void)disSelectedPhotos:(NSArray<IMPhotoModel *>*)photoes{
    for (IMPhotoModel *model in photoes) {
        UIImage *image = [UIImage imageWithCGImage:model.asset.defaultRepresentation.fullResolutionImage];
        
        [[MessageSendModule shareInstance]sendImageMessage:image  Session:_sentity Block:^(DDMessageEntity *msgentity) {
            if(msgentity) [_dataModel insertNewMessage:msgentity];
        }];
    }
    
}
#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    [photos enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[MessageSendModule shareInstance]sendImageMessage:obj  Session:_sentity Block:^(DDMessageEntity *msgentity) {
            if(msgentity) [_dataModel insertNewMessage:msgentity];
        }];
    }];
}
- (ChatRecordPromtView *)recordPromtView {
    if (!_recordPromtView) {
        _recordPromtView = [ChatRecordPromtView recordPromtView];
    }
    return _recordPromtView;
}
- (NameLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[NameLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        //        _titleLabel.font = [UIFont fontWithName:@"iconfont" size:16];
    }
    return _titleLabel;
}
-(void)dealloc{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _inputText.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_inputText removeObserver:self forKeyPath:@"contentSize"];
    [_tableView removeObserver:self forKeyPath:@"contentSize"];
    [[SessionModule sharedInstance]setSessionOpened:_sentity.sessionID Opened:NO];
    [_recordPromtView removeFromSuperview];
    [_tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatBaseCell* cell = obj;
        [cell willDisappare];
    }];
    [_addGroupV removeFromSuperview];
    _addGroupV = nil;
    
    [_photoView removeFromSuperview];
    _photoView = nil;
}
@end

