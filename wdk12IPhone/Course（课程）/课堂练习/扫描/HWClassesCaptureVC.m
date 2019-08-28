//
//  ViewController.m
//  VideoC
//
//  Created by macapp on 16/8/18.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "HWClassesCaptureVC.h"
#import "AVFoundation/AVFoundation.h"
#import "DRQode.h"
#import "BoardNotifyView.h"
@interface HWClassesCaptureVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) BoardNotifyView *boardView;

@property (strong, nonatomic) UIImageView *avImage;
@property (nonatomic, weak) AVCaptureVideoDataOutput *videoOut;
@end

@implementation HWClassesCaptureVC
{
    AVCaptureSession* _avSession;
    dispatch_queue_t  _avQueue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.avImage = [UIImageView new];
    [self.view addSubview:self.avImage];
    [self.avImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    self.boardView = [[BoardNotifyView alloc] init];
    [self.boardView loadFilter];
    
    [self.view addSubview:self.boardView];
    [self.boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    self.boardView.opaque = YES;
    self.boardView.backgroundColor = [UIColor clearColor];
    _avQueue = dispatch_queue_create("com.avqueue.wd", NULL);
    // Do any additional setup after loading the view, typically from a nib.
    _avSession = [[AVCaptureSession alloc] init];
    _avSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    [_avSession addInput:captureInput];
    
    AVCaptureVideoDataOutput *videoOut =  [[AVCaptureVideoDataOutput alloc]init];
    
    videoOut.videoSettings = [NSDictionary dictionaryWithObject:
                              [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey];

    [videoOut setSampleBufferDelegate:self queue:_avQueue];
    [_avSession addOutput:videoOut];
    for (AVCaptureConnection * av in videoOut.connections){
        av.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    _videoOut = videoOut;
    [_avSession startRunning];
   
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //Landscape : 横屏  Portrait: 竖屏
    for (AVCaptureConnection * av in _videoOut.connections){
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;

        } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

  
    UIImage* image = [self imageFromSampleBuffer:sampleBuffer];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_boardView setIMGWidth:image.size.width Height:image.size.height];
        [_avImage setImage:image];
    });
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[DRQode shareInstance]PushPixelBuffer:imageBuffer Block:^(NSArray* boards) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_boardView pushBoards:boards];
            [self onBoradsOut:boards];
        });
    }];
}
-(void)onBoradsOut:(NSArray*)boards{
    
}
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
