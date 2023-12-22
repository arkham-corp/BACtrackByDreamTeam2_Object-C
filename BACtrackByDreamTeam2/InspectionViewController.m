//
//  InspectionViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "InspectionViewController.h"
#import "AppConsts.h"

@interface InspectionViewController () <BacTrackAPIDelegate>
{
    BacTrackAPI *mBacTrack;
    NSInteger mUseCamera;
    NSInteger mTakePhoto;
}
@end

@protocol MyProtocol
- (void)getBreathalyzerSerialNumber;
@end

@interface InspectionViewController () <AVCapturePhotoCaptureDelegate>
{
    
}

@end

@implementation InspectionViewController {
    AVCaptureVideoDataOutput *_dataOutput;
}

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//20231214
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"測定"];
    } else {
        [self setTitle:@"測定（無通信モード）"];
    }
    
    mProgressView.hidden = false;
    mProgressView.progressTintColor = [UIColor orangeColor];
    [mProgressView setProgress:0.0];

//20231214
    
    mReadingLabel.text = @"";
    mBatteryLabel.text = @"";
    mBatteryLabel2.text = @"";
    
    // 値取得
    
    tvDriver.text = [ud stringForKey:KEY_DRIVER];
    tvCarNo.text = [ud stringForKey:KEY_CAR_NO];
    tvAddress.text = [ud stringForKey:KEY_LOCATION_ADDRESS];
    
    UIFont *font = [UIFont systemFontOfSize:22];
    [tvDriver setFont:font];
    [tvCarNo setFont:font];
    [tvAddress setFont:font];
    [tvDriver setTextColor:[UIColor whiteColor]];
    [tvCarNo setTextColor:[UIColor whiteColor]];
    [tvAddress setTextColor:[UIColor whiteColor]];
    
    // デバイスのスリープタイマーを無効化します。
    UIApplication* application = [UIApplication sharedApplication];
    application.idleTimerDisabled = YES;
}

- (void) setupBacTrack
{
    // アルコールマネージャー準備
    mReadingLabel.text = @"接続中\n10秒ほどお待ち下さい";
    
    mBacTrack = [[BacTrackAPI alloc] initWithDelegate:self AndAPIKey:@"e10582efcaf64f7d90d947c2899b43"];
    
    [mBacTrack startScan];
    [mBacTrack stopScan];
    
    [mBacTrack connectToNearestBreathalyzer];
}

- (void) stopBacTrack
{
    [mBacTrack stopScan];
    [mBacTrack disconnect];
    mBacTrack = nil;
}

- (void) setupAVCapture
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized)
    {
        // プライバシー設定でカメラ使用が許可されている
    }
    else if (status == AVAuthorizationStatusDenied)
    {
        // 　不許可になっている
        mUseCamera = 0;
        return;
    }
    else if (status == AVAuthorizationStatusRestricted)
    {
        // 制限されている
        mUseCamera = 0;
        return;
    }
    
    // カメラの準備
    _captureSesssion = [[AVCaptureSession alloc] init];
    _captureSesssion.sessionPreset = AVCaptureSessionPreset352x288;
    _stillImageOutput = [[AVCapturePhotoOutput alloc] init];
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                          mediaType:AVMediaTypeVideo
                                           position:AVCaptureDevicePositionFront];
    NSArray *captureDevices = [captureDeviceDiscoverySession devices];
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            camera = device;
        }
    }
    NSError *error = [[NSError alloc] init];
    
    if (camera == nil)
    {
        mUseCamera = 0;
    }
    else
    {
        mUseCamera = 1;
        
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
        if ([_captureSesssion canAddInput:_videoInput]) {
            [_captureSesssion addInput:_videoInput];
            if ([_captureSesssion canAddOutput:_stillImageOutput]) {
                [_captureSesssion addOutput:_stillImageOutput];
                [_captureSesssion startRunning];
                AVCaptureVideoPreviewLayer* captureVideoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSesssion];
                captureVideoLayer.frame = imageView.bounds;
                captureVideoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                [imageView.layer addSublayer:captureVideoLayer];
            }
        }
    }
}

- (void) stopAVCapture
{
    [_captureSesssion stopRunning];
    for (AVCaptureOutput *output in _captureSesssion.outputs) {
          [_captureSesssion removeOutput:output];
     }
    
     for (AVCaptureInput *input in _captureSesssion.inputs) {
          [_captureSesssion removeInput:input];
     }
    
    _stillImageOutput = nil;
    _videoInput = nil;
    _captureSesssion = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupBacTrack];
    [self setupAVCapture];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopBacTrack];
    [self stopAVCapture];
    
    // デバイスのスリープタイマーを有効化します。
    UIApplication* application = [UIApplication sharedApplication];
    application.idleTimerDisabled = NO;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    imageView.image = [self imageFromSampleBufferRef:sampleBuffer];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/***** BacTrack Callback *****/

//API Key valid, you can now connect to a breathlyzer
-(void)BacTrackAPIKeyAuthorized
{
    
}

//API Key declined for some reason
-(void)BacTrackAPIKeyDeclined:(NSString *)errorMessage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                             message:@"APIKeyの認証に失敗しました"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
       //ボタンがタップされた際の処理
   }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)BacTrackError:(NSError*)error
{
    if(error)
    {
        int error_code = (int) error.code;
        NSString *str_error = @"";
        
        if (error_code == MOBILE__ERROR_TIME_OUT)
        {
            str_error = @"時間切れです";
        }
        else if (error_code == MOBILE__ERROR_BLOW_ERROR)
        {
            str_error = @"息の検出に失敗しました";
        }
        else if (error_code == MOBILE__ERROR_OUT_OF_TEMPERATURE)
        {
            str_error = @"動作温度範囲外です";
        }
        else if (error_code == MOBILE__ERROR_LOW_BATTERY)
        {
            str_error = @"バッテリー残量不足です";
        }
        else if (error_code == MOBILE__ERROR_CALIBRATION_FAIL)
        {
            str_error = @"キャリブレーション失敗";
        }
        else if (error_code == MOBILE__ERROR_NOT_CALIBRATED)
        {
            str_error = @"キャリブレーションションされていません";
        }
        else if (error_code == MOBILE__ERROR_COM_ERROR)
        {
            str_error = @"COMエラーが発生しました";
        }
        else if (error_code == MOBILE__ERROR_INFLOW_ERROR)
        {
            str_error = @"息の検出に失敗しました";
        }
        else if (error_code == MOBILE__ERROR_SOLENOID_ERROR)
        {
            str_error = @"ソレノイドエラーが発生しました";
        }
        else if (error_code == ERROR_SENSOR)
        {
            str_error = @"センサーエラーが発生しました";
        }
        else if (error_code == ERROR_BAC_UPPER_LIMIT)
        {
            str_error = @"測定上限値を超えました";
        }
        else
        {
            str_error = @"エラーが発生しました";
        }
        
        NSLog(@"CHECK %@", error.description);
        //NSString* errorDescription = [error localizedDescription];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:str_error
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
           [self.navigationController popViewControllerAnimated:YES];
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

// Initialized countdown from number
-(void)BacTrackCountdown:(NSNumber *)number executionFailure:(BOOL)failure
{
    if (failure)
    {
        [self BacTrackError:nil];
        return;
    }
    else
    {
//20231211

        float i = [number doubleValue];
        if(i > 10) {
            i = 10;
        }
        float progress = fabs(((i-10)*-1)/10);
        NSLog(@"%@", [NSString stringWithFormat: @"%.2f", progress] );

        [mProgressView setProgress:progress + 0.1 animated:YES];

        NSString *str = @"準備中 ";
//        NSString *str = [NSString stringWithFormat:@"%@%.0f",str1,i];
        mReadingLabel.text = str;
//        mReadingLabel.text = @"準備中";
//20231211
    }
}

// Tell the user to start
- (void)BacTrackStart
{
    mProgressView.hidden = true;
    [mProgressView setProgress:0.0];
    mProgressView.progressTintColor = [UIColor blueColor];
    mProgressView.hidden = false;

    mTakePhoto = 0;
    mReadingLabel.text = @"息を吐いてください!";
}

// Tell the user to blow
/*
- (void)BacTrackBlow
{
    mReadingLabel.text = @"息を吐き続けてください!";
    
    if (mUseCamera == 1 && mTakePhoto == 0)
    {
        mTakePhoto = 1;
        [self willTakePhoto];
    }
}
*/

-(void)BacTrackBlow:(NSNumber*)breathFractionRemaining
{
//20231211
    float i = [breathFractionRemaining doubleValue];
    if(i > 1) {
        i = 1;
    }
    float progress = fabs(((i-1)*-1));
    [mProgressView setProgress:progress + 0.1 animated:YES];
    NSLog(@"%@", [NSString stringWithFormat: @"%.2f", progress] );
    
    //NSString *str = @"息を吐き続けてください! ";
    mReadingLabel.text = [NSString stringWithFormat: @"息を吐き続けてください! %.f ％", progress*100] ;
 //    mReadingLabel.text = @"息を吐き続けてください!";
//20231211
    if (mUseCamera == 1 && mTakePhoto == 0)
    {
        mTakePhoto = 1;
        [self willTakePhoto];
    }
}

- (void)BacTrackAnalyzing
{
    mProgressView.hidden = true;
    mReadingLabel.text = @"解析中";
}


-(void)BacTrackResults:(CGFloat)bac
{
    //mReadingLabel.text = @"Your Result";
    //mResultLabel.text = [NSString stringWithFormat: @"%.2f", bac];
        
    // 現在日時
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
    NSString *inspection_time = [df stringFromDate:[NSDate date]];
    
    // 値保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSString stringWithFormat: @"%.3f", bac] forKey:KEY_ALCOHOL_VALUE];
    [ud setObject:inspection_time forKey:KEY_INSPECTION_TIME];
    [ud synchronize];
    
    // 停止
    [self stopBacTrack];
    [self stopAVCapture];
    
    // 移動
    resultViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
    [self.navigationController pushViewController:resultViewController animated:YES];
}

-(void)BacTrackConnected:(BACtrackDeviceType)device
{
    NSLog(@"Connected to BACtrack device");
    
    [mBacTrack performSelector:@selector(getBreathalyzerSerialNumber)];
    [mBacTrack getBreathalyzerBatteryLevel];
    [mBacTrack startCountdown];
}

-(void)BacTrackDisconnected
{
    mReadingLabel.text = @"切断されました";
    
    /*
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                 message:@"You are now disconnected from your BACtrack device"
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
     */
}

-(void)BacTrackConnectTimeout
{
    //Callback for device connection timeout; can use method to reset UI etc
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                             message:@"接続時間切れ"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
       //ボタンがタップされた際の処理
   }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(NSTimeInterval)BacTrackGetTimeout
{
    //Optional, sets a callback timeout timer (in seconds)
    return 10;
}

-(void)BacTrackFoundBreathalyzer:(Breathalyzer*)breathalyzer
{
    //Can use to store/record device id, breathalyzer type, etc.
    //Here I've just listed the breathalyzer type
    NSLog(@"BacTrackFoundBreathalyzer: %@", breathalyzer.uuid);
    // 値保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:breathalyzer.uuid forKey:KEY_BREATHALYZER_UUID];
    [ud synchronize];
}

- (void) BacTrackSerial:(NSString *)serial_hex
{
    // 値保存 取得できたらUUIDを上書き
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:serial_hex forKey:KEY_BREATHALYZER_UUID];
    [ud synchronize];
    
    NSLog(@"BacTrackSerial: %@", serial_hex);
}

-(void)BacTrackUseCount:(NSNumber*)number
{
    NSLog(@"Use count:, %d", number.intValue);

    // 値保存 取得できたらUUIDを上書き
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSString stringWithFormat: @"%d", number.intValue] forKey:KEY_BREATHALYZER_USE_COUNT];
    [ud synchronize];
}

- (void) BacTrackBatteryVoltage:(NSNumber *)number
{
    NSLog(@"Battery Voltage: %f", [number floatValue]);
}

- (void) BacTrackBatteryLevel:(NSNumber *)number
{
    NSLog(@"Battery Level: %d", [number intValue]);
    // 値保存
    NSString *str_battery_label = @"";
    NSString *str_battery_label2 = @"";
    
    int battery_level = [number intValue];
    if (battery_level == 0)
    {
        str_battery_label = @"電池残量：少";
        str_battery_label2 = @"充電してください";
        [mBatteryLabel2 setTextColor:[UIColor systemRedColor]];
    }
    else if (battery_level < 3)
    {
        str_battery_label = @"電池残量：中";
        str_battery_label2 = @"";
        [mBatteryLabel2 setTextColor:[UIColor orangeColor]];
    }
    else
    {
        str_battery_label = @"電池残量：多";
        str_battery_label2 = @"";
        [mBatteryLabel2 setTextColor:[UIColor whiteColor]];
    }
    
    mBatteryLabel.text = str_battery_label;
    mBatteryLabel2.text = str_battery_label2;
}

-(void)BacTrackFirmwareVersion:(NSString*)version
{
    NSLog(@"%@", version);
}

- (void)willTakePhoto {
    AVCapturePhotoSettings* settings = [[AVCapturePhotoSettings alloc] init];
    settings.flashMode = AVCaptureFlashModeAuto;
    for(AVCaptureConnection *connection in self.stillImageOutput.connections) {
        if (connection.supportsVideoOrientation) {
            connection.videoOrientation = videoOrientationFromDeviceOrientation([UIDevice currentDevice].orientation);
        }
    }
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef    buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t*    base;
    size_t      width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef    cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef  cgImage;
    UIImage*    image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error
{
    NSData *photoData = [photo fileDataRepresentation];
    UIImage* resultImage = [[UIImage alloc] initWithData:photoData];
    NSData *data = UIImageJPEGRepresentation(resultImage, 1.0);
    // NSLog(@"Image length: %lu bytes", (unsigned long)[data length]);
    
    // 値保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:KEY_PHOTO];
    [ud synchronize];
}

/*
-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(nonnull AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error
{
    NSData* photoData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage* resultImage = [[UIImage alloc] initWithData:photoData];
    NSData *data = UIImageJPEGRepresentation(resultImage, 1.0);
    // NSLog(@"Image length: %lu bytes", (unsigned long)[data length]);
    
    // 値保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:KEY_PHOTO];
    [ud synchronize];
}
*/

static AVCaptureVideoOrientation videoOrientationFromDeviceOrientation(UIDeviceOrientation deviceOrientation) {
    AVCaptureVideoOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationUnknown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

@end
