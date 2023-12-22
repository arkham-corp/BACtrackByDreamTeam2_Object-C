//
//  GPSViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "GPSViewController.h"
#import "AppConsts.h"

@interface GPSViewController ()
{
    NSInteger mChangeAuthorizationStatus;
    NSInteger mLocation;
}
@end

@implementation GPSViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//20231214
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"位置取得"];
    } else {
        [self setTitle:@"位置取得（無通信モード）"];
    }
//20231214

    buttonExec.exclusiveTouch = true;
    
    //mChangeAuthorizationStatus = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        self->mChangeAuthorizationStatus = 0;
    });
    
    // 住所初期化
    [ud setFloat:0.0f forKey:KEY_LOCATION_LATITUDE];
    [ud setFloat:0.0f forKey:KEY_LOCATION_LONGITUDE];
    [ud setObject:@"" forKey:KEY_LOCATION_ADDRESS];
    [ud synchronize];
    
    //GPSの利用可否判断
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"GPSが無効です"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
           self->buttonExec.enabled = true;
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{    
    buttonExec.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    
    // 逆ジオコーディングの開始
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            // エラーが発生している
        } else {
            if (0 < [placemarks count]) {
                // 結果はひとつしかない
                CLPlacemark *placemark= [placemarks objectAtIndex:0];
                
                NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@",
                                     [placemark administrativeArea],
                                     [placemark locality],
                                     [placemark thoroughfare],
                                     [placemark subThoroughfare]
                                     ];
                
                // 住所保存
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setFloat:location.coordinate.latitude forKey:KEY_LOCATION_LATITUDE];
                [ud setFloat:location.coordinate.longitude forKey:KEY_LOCATION_LONGITUDE];
                [ud setObject:address forKey:KEY_LOCATION_ADDRESS];
                [ud synchronize];
                
                [self->lblAddress setText:address];
                [self->buttonExec setTitle:@"決定" forState:UIControlStateNormal];
            }
        }
    }];
}

// CLLocationManager オブジェクトにデリゲートオブジェクトを設定すると初回に呼ばれる
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    if (@available(iOS 14.0, *)) {
        if (manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
            // ユーザが位置情報の使用を許可していない
            // NSLocationWhenInUseUsageDescriptionに設定したメッセージでユーザに確認
            [locationManager stopUpdatingLocation];
            [locationManager requestWhenInUseAuthorization];
            [locationManager startUpdatingLocation];
            self->mLocation = 1;
        }
    } else {
        // Fallback on earlier versions
    }
}

// CLLocationManager オブジェクトにデリゲートオブジェクトを設定すると初回に呼ばれる
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
        // NSLocationWhenInUseUsageDescriptionに設定したメッセージでユーザに確認
        [locationManager requestWhenInUseAuthorization];
        self->mLocation = 1;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (self->mLocation != 1)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"位置情報が取得できませんでした。"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
           self->buttonExec.enabled = true;
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    drivingDivViewController = [[DrivingDivViewController alloc] initWithNibName:@"DrivingDivViewController" bundle:nil];
    [self.navigationController pushViewController:drivingDivViewController animated:YES];
}

@end
