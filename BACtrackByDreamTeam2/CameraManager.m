//
//  CameraManager.m
//

#import "CameraManager.h"

@interface CameraManager () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _sessionQueue;
    BOOL _isFaceDetected;
    BOOL _isTakingPhoto;
    NSTimer *_timeoutTimer;
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation CameraManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutSeconds = 30;
        _useFaceDetection = NO;
    }
    return self;
}

#pragma mark - Public

- (void)startCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if (status == AVAuthorizationStatusAuthorized) {
        [self _initCamera];
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self _initCamera];
                } else {
                    [self.delegate cameraManagerDidDenied];
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cameraManagerDidDenied];
        });
    }
}

- (void)stopCamera {
    [self _stopTimeoutTimer];
    if (!_sessionQueue) return;
    dispatch_async(_sessionQueue, ^{
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewLayer removeFromSuperlayer];
            self.previewLayer = nil;
        });
    });
}

- (void)takePhoto {
    // 手動撮影はフラグで次フレームをキャプチャ
    if (self.useFaceDetection) return;
    _isTakingPhoto = YES;
}

#pragma mark - Private: Camera Setup

- (void)_initCamera {
    // 毎回新規作成（使い回しによる状態汚染を防ぐ）
    self.session = [[AVCaptureSession alloc] init];
    _sessionQueue = dispatch_queue_create("com.app.camera.sessionQueue", DISPATCH_QUEUE_SERIAL);
    _isFaceDetected = NO;
    _isTakingPhoto = NO;

    dispatch_async(_sessionQueue, ^{
        [self.session beginConfiguration];

        // フロントカメラ取得
        AVCaptureDevice *camera = nil;

        AVCaptureDeviceDiscoverySession *discoverySession =
            [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[
                AVCaptureDeviceTypeBuiltInWideAngleCamera
            ]
            mediaType:AVMediaTypeVideo
            position:AVCaptureDevicePositionFront];

        for (AVCaptureDevice *d in discoverySession.devices) {
            if (d.position == AVCaptureDevicePositionFront) {
                camera = d;
                break;
            }
        }

        if (!camera) {
            [self.session commitConfiguration];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraManagerDidDenied];
            });

            return;
        }

        // Input
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        if (error || ![self.session canAddInput:input]) {
            [self.session commitConfiguration];
            return;
        }
        [self.session addInput:input];

        // Output（VideoDataOutputのみ - PhotoOutputは使わない）
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        output.alwaysDiscardsLateVideoFrames = YES;
        output.videoSettings = @{
            (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
        };
        [output setSampleBufferDelegate:self queue:self->_sessionQueue];

        if ([self.session canAddOutput:output]) {
            [self.session addOutput:output];
            AVCaptureConnection *conn = [output connectionWithMediaType:AVMediaTypeVideo];
            if (conn.isVideoOrientationSupported) {
                conn.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
            if (conn.isVideoMirroringSupported) {
                conn.videoMirrored = YES;
            }
        }

        // プリセット
        if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            self.session.sessionPreset = AVCaptureSessionPreset640x480;
        }

        // 1. まず確実に設定をコミットして、設定モードを終わらせる
        [self.session commitConfiguration];

        // 2. 設定が確実に確定した後に、セッションを開始する
        [self.session startRunning];

        // 3. セッションが動き出してから、UI（プレビューやタイマー）をメインスレッドで構築する
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _setupPreviewLayer];

            if (self.useFaceDetection) {
                [self _startTimeoutTimer];
            }
        });
    });
}

- (void)_setupPreviewLayer {
    // 既存レイヤー削除
    [self.previewLayer removeFromSuperlayer];

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.previewView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    if (_isFaceDetected || (_isTakingPhoto == NO && !self.useFaceDetection)) return;

    if (self.useFaceDetection) {
        // 顔検出モード
        if (_isFaceDetected) return;

        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        if ([detector featuresInImage:ciImage].count == 0) return;

        _isFaceDetected = YES;
    } else {
        // 手動撮影モード
        if (!_isTakingPhoto) return;
        _isTakingPhoto = NO;
    }

    // フレームからUIImageを生成
    UIImage *photo = [self _imageFromSampleBuffer:sampleBuffer];
    UIImage *resized = [self _resizeImage:photo maxSize:320];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self _stopTimeoutTimer];
        [self.delegate cameraManagerDidCapturePhoto:resized];
    });
}

#pragma mark - Private: Image

- (UIImage *)_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext context];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

- (UIImage *)_resizeImage:(UIImage *)image maxSize:(CGFloat)maxSize {
    CGFloat scale = MIN(maxSize / image.size.width, maxSize / image.size.height);
    CGSize newSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

#pragma mark - Private: Timer

- (void)_startTimeoutTimer {
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutSeconds
                                                     target:self
                                                   selector:@selector(_handleTimeout)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)_stopTimeoutTimer {
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

- (void)_handleTimeout {
    _isFaceDetected = YES; // 以降のフレーム処理をブロック
    [self stopCamera];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cameraManagerDidTimeout];
    });
}

- (void)stopCameraWithCompletion:(void (^)(void))completion {
    [self _stopTimeoutTimer];
    if (!_sessionQueue) {
        if (completion) completion();
        return;
    }
    dispatch_async(_sessionQueue, ^{
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewLayer removeFromSuperlayer];
            self.previewLayer = nil;
            if (completion) completion();  // 完全停止後にコールバック
        });
    });
}

@end
