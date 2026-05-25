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
#import "CameraManager.h"

@interface InspectionViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, CameraManagerDelegate>

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
@property (nonatomic, strong) CameraManager *cameraManager;
@end

@interface InspectionViewController () <BacTrackAPIDelegate>
{
    BacTrackAPI *mBacTrack;
    NSInteger mTakePhoto;
}
@end

