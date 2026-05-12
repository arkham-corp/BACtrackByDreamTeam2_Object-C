//
//  GPSViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC.
//

#import "GPSViewController.h"
#import "AppConsts.h"

@interface GPSViewController () {
    NSInteger mChangeAuthorizationStatus;
    NSInteger mLocation;
}
@end

@implementation GPSViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 通信状態によってタイトル変更
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];
    if ([status isEqual:@"0"]) {
        [self setTitle:@"位置取得"];
    } else {
        [self setTitle:@"位置取得（無通信モード）"];
    }

    buttonExec.exclusiveTouch = true;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->mChangeAuthorizationStatus = 0;
    });
    
    // 住所初期化
    [ud setFloat:0.0f forKey:KEY_LOCATION_LATITUDE];
    [ud setFloat:0.0f forKey:KEY_LOCATION_LONGITUDE];
    [ud setObject:@"" forKey:KEY_LOCATION_ADDRESS];
    [ud synchronize];
    
    // CLLocationManager 初期化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // 許可状態を確認して、必要ならリクエスト
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    buttonExec.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = manager.authorizationStatus;

    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // 初回許可リクエスト
            [manager requestWhenInUseAuthorization];
            self->mLocation = 1;
            break;

        case kCLAuthorizationStatusDenied:
            NSLog(@"位置情報が拒否されています");
            break;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"位置情報が許可されています");

            // 警告原因の locationServicesEnabled は削除
            // 許可がある場合はそのまま開始
            [manager startUpdatingLocation];
            break;

        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    // 逆ジオコーディング
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"逆ジオコーディングエラー: %@", error.localizedDescription);
        } else if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@",
                                 placemark.administrativeArea ?: @"",
                                 placemark.locality ?: @"",
                                 placemark.thoroughfare ?: @"",
                                 placemark.subThoroughfare ?: @""];
            
            // 保存
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setFloat:location.coordinate.latitude forKey:KEY_LOCATION_LATITUDE];
            [ud setFloat:location.coordinate.longitude forKey:KEY_LOCATION_LONGITUDE];
            [ud setObject:address forKey:KEY_LOCATION_ADDRESS];
            [ud synchronize];
            
            // UI更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->lblAddress setText:address];
                [self->buttonExec setTitle:@"決定" forState:UIControlStateNormal];
            });
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self->mLocation != 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"位置情報が取得できませんでした。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            self->buttonExec.enabled = true;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Button Action

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    drivingDivViewController = [[DrivingDivViewController alloc] initWithNibName:@"DrivingDivViewController" bundle:nil];
    [self.navigationController pushViewController:drivingDivViewController animated:YES];
}

@end
