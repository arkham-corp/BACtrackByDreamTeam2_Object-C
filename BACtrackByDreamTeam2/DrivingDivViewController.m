//
//  DriverViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "DrivingDivViewController.h"
#import "AppConsts.h"

@implementation DrivingDivViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"乗務前後"];
    } else {
        [self setTitle:@"乗務前後（無通信モード）"];
    }

    buttonExec.exclusiveTouch = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    buttonExec.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    [self.view endEditing:YES];
    
    NSString *drivingDiv = [NSString stringWithFormat:@"%ld", (long)segmentedDrivingDiv.selectedSegmentIndex];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:drivingDiv forKey:KEY_DRIVING_DIV];
    [ud synchronize];

    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

    if([status isEqual:(@"0")]) {
        NSString *recognition_enable = [ud stringForKey:KEY_RECOGNITION_ENABLE];
        if ([recognition_enable isEqualToString:@"1"] ) {
            faceRecognitionViewController = [[FaceRecognitionViewController alloc] initWithNibName:@"FaceRecognitionViewController" bundle:nil];
            [self.navigationController pushViewController:faceRecognitionViewController animated:YES];
        }
        else
        {
            driverViewController = [[DriverViewController alloc] initWithNibName:@"DriverViewController" bundle:nil];
            [self.navigationController pushViewController:driverViewController animated:YES];
        }
    } else {
        driverViewController = [[DriverViewController alloc] initWithNibName:@"DriverViewController" bundle:nil];
        [self.navigationController pushViewController:driverViewController animated:YES];
    }
}

@end
