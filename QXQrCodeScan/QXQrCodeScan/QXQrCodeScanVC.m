//
//  QXOrCodeScanVC.m
//  QXQrCodeScan
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#define QX_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define QX_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define QX_SCREEN_BOUNDS  [UIScreen mainScreen].bounds
#define QX_TOP (QX_SCREEN_HEIGHT-220)/2
#define QX_LEFT (QX_SCREEN_WIDTH-220)/2
#define QX_IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)
#define QX_Height_StatusBar [[UIApplication sharedApplication] statusBarFrame].size.height
#define QX_kScanRect CGRectMake(QX_LEFT, QX_TOP, 220, 220)

#import "QXQrCodeScanVC.h"
#import <AVFoundation/AVFoundation.h>
#import "QXImagePicker.h"

@interface QXQrCodeScanVC ()//<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
}
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) UIImageView *line;
@end

@implementation QXQrCodeScanVC
{
    UIButton * flashBtn;
    BOOL flashBtnHidden;
    UIButton * albumBtn;
    BOOL albumBtnHidden;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self cropPect:QX_kScanRect];
    [self performSelector:@selector(_setupCamera) withObject:nil afterDelay:0.3];
}

- (void)cropPect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    cropLayer.fillRule = kCAFillRuleEvenOdd;
    cropLayer.path = path;
    cropLayer.fillColor = [UIColor blackColor].CGColor;
    cropLayer.opacity = 0.6;
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置
    [self _setup];
    
    // 设置子控件
    [self _setupSubViews];
    
//    [self cropPect:QX_kScanRect];
//    [self performSelector:@selector(_setupCamera) withObject:nil afterDelay:0.3];
}

#pragma mark - 设置
- (void)_setup{
    flashBtnHidden = NO;
    albumBtnHidden = NO;
    upOrdown = NO;
    num = 0;
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 设置子控件
- (void)_setupSubViews{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:QX_kScanRect];
    imageView.image = [UIImage imageNamed:@"qr_pick_bg"];
    [self.view addSubview:imageView];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.frame = CGRectMake(imageView.frame.origin.x, CGRectGetMaxY(imageView.frame), imageView.frame.size.width, 44);
    titleL.font = [UIFont systemFontOfSize:14.0];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.text = @"将扫描框对准二维码即可自动扫描";
    [self.view addSubview:titleL];
    
    if (!flashBtnHidden) {
        flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        flashBtn.frame = CGRectMake(imageView.frame.origin.x, CGRectGetMaxY(imageView.frame)-44, imageView.frame.size.width, 44);
        [flashBtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
        [flashBtn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
        flashBtn.backgroundColor = [UIColor clearColor];
        flashBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        flashBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [flashBtn addTarget:self action:@selector(openflashClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:flashBtn];
    }
    
    if (!albumBtnHidden) {
        albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        albumBtn.frame = CGRectMake(titleL.frame.origin.x, CGRectGetMaxY(titleL.frame)+5, imageView.frame.size.width, 44);
        [albumBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
        albumBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        albumBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [albumBtn addTarget:self action:@selector(openAlbumClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:albumBtn];
    }
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(QX_LEFT, QX_TOP+10, 220, 2)];
    _line.image = [UIImage imageNamed:@"qr_line.png"];
    [self.view addSubview:_line];
    
    if (!self.navigationController) {
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(10, QX_Height_StatusBar, 44, 44);
        [closeBtn setImage:[UIImage imageNamed:@"qr_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationUpDown) userInfo:nil repeats:YES];
}

#pragma mark - 初始化摄像头
- (void)_setupCamera{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_device == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = QX_TOP / QX_SCREEN_HEIGHT;
    CGFloat left = QX_LEFT / QX_SCREEN_WIDTH;
    CGFloat width = 220 / QX_SCREEN_WIDTH;
    CGFloat height = 220 / QX_SCREEN_HEIGHT;
    
    [_output setRectOfInterest:CGRectMake(top, left, height, width)];
    
    //session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // start
    [_session startRunning];;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"stringValue = %@",stringValue);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.compBlick) {
                __weak typeof(self) weakSelf = self;
                self.compBlick(weakSelf, nil, stringValue);
            }
        });
    }else{
        return;
    }
}

- (void)openflashClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.isSelected == YES) { //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else{//关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)openAlbumClick:(UIButton *)sender{
    QXImagePicker * picker = [QXImagePicker sharedInstance];
    [picker startCurrentWithVC:self];
    [picker setPickerCompletion:^(QXImagePicker * _Nonnull picker, NSError * _Nonnull error, UIImage * _Nonnull image) {
        if (!error) {
            //图片可用
            CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
            NSData*imageData = UIImagePNGRepresentation(image);
            CIImage*ciImage = [CIImage imageWithData:imageData];
            NSArray*features = [detector featuresInImage:ciImage];
            CIQRCodeFeature*feature = [features objectAtIndex:0];
            NSString*scannedResult = feature.messageString;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.compBlick) {
                    __weak typeof(self) weakSelf = self;
                    self.compBlick(weakSelf,nil,scannedResult);
                }
            });
        }else{
            //error 中会有错误的说明
        }
    }];
}

- (void)closeBtnAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)animationUpDown{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(QX_LEFT, QX_TOP+10+2*num, 220, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }else {
        num --;
        _line.frame = CGRectMake(QX_LEFT, QX_TOP+10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

- (void)hiddenFlashBtn:(BOOL)type{
    flashBtnHidden = type;
}

- (void)hiddenAlbumBtn:(BOOL)type{
    albumBtnHidden = type;
}

//- (BOOL)prefersStatusBarHidden{
//    return  YES;
//}

@end
