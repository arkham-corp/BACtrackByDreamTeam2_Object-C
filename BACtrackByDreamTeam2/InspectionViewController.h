//
//  InspectionViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BACtrack.h"
#import "ResultViewController.h"

@interface InspectionViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    ResultViewController *resultViewController;
    
    IBOutlet UITextView *tvLavelDriver;
    IBOutlet UITextView *tvLavelCarNo;
    IBOutlet UITextView *tvLavelAddress;
    
    IBOutlet UITextView *tvDriver;
    IBOutlet UITextView *tvCarNo;
    IBOutlet UITextView *tvAddress;
    
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel *mBatteryLabel;
    IBOutlet UILabel *mBatteryLabel2;
    IBOutlet UILabel *mReadingLabel;
    IBOutlet UIProgressView *mProgressView;

}

@property (nonatomic, retain) id <BacTrackAPIDelegate> delegate;
@property (nonatomic) AVCaptureSession  *captureSesssion;
@property AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCapturePhotoOutput *stillImageOutput;

@end
