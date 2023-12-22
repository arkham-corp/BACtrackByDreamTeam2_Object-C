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
    
//20231214
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"乗務前後"];
    } else {
        [self setTitle:@"乗務前後（無通信モード）"];
    }
//20231214

    buttonExec.exclusiveTouch = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    buttonExec.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    
    // 値保存
    NSString *drivingDiv = [NSString stringWithFormat:@"%ld", (long)segmentedDrivingDiv.selectedSegmentIndex];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:drivingDiv forKey:KEY_DRIVING_DIV];
    [ud synchronize];
            
    // 移動
    driverViewController = [[DriverViewController alloc] initWithNibName:@"DriverViewController" bundle:nil];
    [self.navigationController pushViewController:driverViewController animated:YES];
}

@end
