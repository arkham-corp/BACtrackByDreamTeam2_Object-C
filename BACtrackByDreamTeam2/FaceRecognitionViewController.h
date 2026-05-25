//
//  FaceRecognitionViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2026/03/25.
//  Copyright © 2026年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CarNoViewController.h"
#import "CameraManager.h"
#import "MyButton.h"

@interface FaceRecognitionViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, CameraManagerDelegate, UITextFieldDelegate, NSURLSessionDataDelegate,  AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CarNoViewController *carNoViewController;

    __weak IBOutlet UITextField *numberTextField;
    IBOutlet UITextView *tvLavelDriver;
    IBOutlet UITextView *tvDriver;
    __weak IBOutlet UITextView *tvMessage;
    IBOutlet UIImageView* imageView;
    //__weak IBOutlet UIButton *buttonExec;
    __weak IBOutlet MyButton *buttonExecute;
    NSMutableData *receivedData;
}
@property (nonatomic, strong) CameraManager *cameraManager;
@end

