//
//  CameraManager.h
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraManagerDelegate <NSObject>
/// 顔を検出して撮影が完了したときに呼ばれる
- (void)cameraManagerDidCapturePhoto:(UIImage *)image;
/// タイムアウトしたときに呼ばれる（顔検出モードのみ）
- (void)cameraManagerDidTimeout;
/// カメラ権限が拒否されているときに呼ばれる
- (void)cameraManagerDidDenied;

@end

@interface CameraManager : NSObject

@property (nonatomic, weak) id<CameraManagerDelegate> delegate;

/// プレビューを表示するビュー（外から渡す）
@property (nonatomic, weak) UIView *previewView;

/// 顔を自動検出して撮影するか（YES=FaceRecognition用 / NO=手動撮影用）
@property (nonatomic, assign) BOOL useFaceDetection;

/// タイムアウト秒数（useFaceDetection=YESのときのみ有効、デフォルト30秒）
@property (nonatomic, assign) NSInteger timeoutSeconds;

/// カメラを起動する
- (void)startCamera;

/// カメラを停止する
- (void)stopCamera;

/// 手動で撮影する（useFaceDetection=NOのときに使う）
- (void)takePhoto;

- (void)stopCameraWithCompletion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
