//
//  GPSViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DrivingDivViewController.h"

@interface GPSViewController : UIViewController <CLLocationManagerDelegate>
{
    DrivingDivViewController *drivingDivViewController;
    IBOutlet UILabel *lblAddress;
    IBOutlet UIButton *buttonExec;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
