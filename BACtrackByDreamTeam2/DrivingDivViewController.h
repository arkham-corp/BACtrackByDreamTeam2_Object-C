//
//  DriverViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverViewController.h"
#import "FaceRecognitionViewController.h"

@interface DrivingDivViewController : UIViewController
{
    DriverViewController *driverViewController;
    FaceRecognitionViewController *faceRecognitionViewController;
    __weak IBOutlet UISegmentedControl *segmentedDrivingDiv;
    __weak IBOutlet UIButton *buttonExec;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
