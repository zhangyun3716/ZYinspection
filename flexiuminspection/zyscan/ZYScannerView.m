/*
 *	_________         __       __
 * |______  /         \ \     / /
 *       / /           \ \   / /
 *      / /             \ \ / /
 *     / /               \   /
 *    / /                 | |
 *   / /                  | |
 *  / /_________          | |
 * /____________|         |_|
 *
 Copyright (c) 2011 ~ 2016 zhangyun. All rights reserved.
 */

#import "ZYScannerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZYScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *perviewLayer;
@property (nonatomic, strong) UIView *scannerView;
@property (nonatomic, strong)UIButton *dakaizhaoming;
@end

@implementation ZYScannerView


+ (ZYScannerView *)sharedScannerView {
    static ZYScannerView *v = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        v = [[ZYScannerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    });
    return v;
}

- (void)showOnView:(UIView *)view block:(BackBlock)block{
    self.back = [block copy];
    [self.session startRunning];
    [view addSubview:self];
    self.hidden = NO;
}

- (void)dismiss {
    [self.session stopRunning];
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - 内部调用

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        _scannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
        _scannerView.backgroundColor = [UIColor clearColor];
        _scannerView.layer.borderWidth = 2.0;
        _scannerView.layer.borderColor = [UIColor whiteColor].CGColor;
        _scannerView.center = self.center;
        
        _dakaizhaoming=[[UIButton alloc  ]initWithFrame:CGRectMake(10, self.frame.size.height-120, 120, 40)];
        self.dakaizhaoming.layer.cornerRadius=10;//self.imageView.frame.size.width/2+5;//裁成圆角
        self.dakaizhaoming.layer.masksToBounds=YES;//隐藏裁剪掉的部分
        _dakaizhaoming.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
        [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
        UIView *textview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 23)];
        textview.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
        [self addSubview:textview];
        UILabel *textlable=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, self.frame.size.width, 40)];
        textlable.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"textlable"];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"textlable"]);
        textlable.textColor=[UIColor whiteColor];
        textlable.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
        textlable.textAlignment=NSTextAlignmentCenter;
        textlable.font=[UIFont systemFontOfSize:20];
//        textlable.layer.cornerRadius=7;//self.imageView.frame.size.width/2+5;//裁成圆角
//        textlable.layer.masksToBounds=YES;//隐藏裁剪掉的部分
        [self addSubview:textlable];
        [_dakaizhaoming addTarget:self action:@selector(setDakaizhaoming:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dakaizhaoming];
        UIButton *blackbtn= [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width -130, self.frame.size.height-120, 120, 40)];
        blackbtn.layer.cornerRadius=7;//self.imageView.frame.size.width/2+5;//裁成圆角
        blackbtn.layer.masksToBounds=YES;//隐藏裁剪掉的部分
        blackbtn.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
        [blackbtn setTitle:@"返回" forState:UIControlStateNormal];
        [blackbtn addTarget:self action:@selector(black) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:blackbtn];
        
        [self addSubview:_scannerView];
        [self start];
        
    }
    return self;
}

- (void)start {
    // 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"启动摄像头失败：%@",error.localizedDescription);
        return;
    }
    
    // 设置输出元素
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session addInput:input];
    [session addOutput:output];
    
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 制定输出类型
    [output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
//     output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 设置预览图次
    AVCaptureVideoPreviewLayer *perviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    perviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    perviewLayer.frame = self.bounds;
    _perviewLayer = perviewLayer;
    
    [self.layer insertSublayer:_perviewLayer atIndex:0];
    //    [self.view.layer addSublayer:_perviewLayer];
    
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect cropRect = _scannerView.frame;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = [UIScreen mainScreen].bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = [UIScreen mainScreen].bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    
    _session = session;

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    
    NSLog(@"%@", metadataObjects);
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if ([[obj type] isEqualToString:AVMetadataObjectTypeCode39Code]||[[obj type] isEqualToString:AVMetadataObjectTypeEAN13Code]||[[obj type] isEqualToString:AVMetadataObjectTypeCode128Code]||[[obj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *bakestr=obj.stringValue;
            if (bakestr!=nil) {
                [self.session stopRunning];
                if (self.back) {
                    self.back(bakestr);
                    [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
                    [self dismiss];
                }
            }
        }
    }
}

//记得返回扫描数据
-(void)black{
    [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
    [self systemLightSwitch:NO];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"PassValueWithNotification" object:nil];
    [self dismiss];
    }
-(void)setDakaizhaoming:(UIButton *)dakaizhaoming{
    UIButton *button = (UIButton *)dakaizhaoming;
    if ([button.titleLabel.text isEqualToString:@"打開照明"]) {
        [self systemLightSwitch:YES];
    } else {
        [self systemLightSwitch:NO];
    }
    
}
- (void)systemLightSwitch:(BOOL)open
{
    if (open) {
        [_dakaizhaoming setTitle:@"關閉照明" forState:UIControlStateNormal];
    } else {
        [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

@end
