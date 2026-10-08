//
//  MainViewController.m
//  BACtrackByDreamTeam
//
//  Created by COM-MAC on 2016/01/15.
//  Copyright © 2016年 COM-MAC. All rights reserved.
//

#import "MainViewController.h"
#import "AppConsts.h"
#import "Realm/Realm.h"

@interface MainViewController () <NSURLSessionDataDelegate>
{
    NSMutableData *receivedData;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // ナビゲーションバーのラージタイトルを強制的にOFFにする
        if (@available(iOS 11.0, *)) {
            self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        }
    // 権限フラグ初期化
    _cameraGranted = NO;
    _locationGranted = NO;
    _bluetoothGranted = NO;

    NSString *appVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSString *schemaVer = [NSString stringWithFormat:@"%llu", config.schemaVersion];
 
    [labelAppVer setText:[NSString stringWithFormat:@"%@ %@", @"appVer：", appVer]];
    [labelSchemaVer setText:[NSString stringWithFormat:@"%@ %@", @"schemaVer：", schemaVer]];
    
    // 前回値取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *agreement = [ud stringForKey:KEY_AGREEMENT];
    [ud setObject:@"0" forKey:KEY_CONECTION_STATUS];//0:接続1:未接続
    [ud setObject:@"0" forKey:KEY_CHECK_MODE];//0:通常1:サーバーへ通信せずに処理を続ける
    [ud synchronize];

    [self setTitle:@"トップ画面"];
    
    buttonExec.enabled = NO;
    
    // 利用規約判定
    if (![agreement isEqualToString:@"1"]) {
        [self showAgreementViewController];
    } else {
        // 同意済み → 権限確認へ
        [self requestCameraPermission];
        [self versionCeck];
    }

}

- (void)showAgreementViewController {
    AgreementViewController *agreementVC = [[AgreementViewController alloc] init];
    agreementVC.completionHandler = ^(BOOL agreed) {
        if (agreed) {
            // 同意 → 権限確認へ
            [self requestCameraPermission];
            [self versionCeck];
        } else {
            // 不同意 → 利用規約画面を再表示
            self->buttonExec.enabled = NO;
        }
    };
    [self presentViewController:agreementVC animated:YES completion:nil];
}

- (void)versionCeck
{
    // NsDate => NSString変換用のフォーマッタを作成
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMddHHmmss"];

    // 日付(NSDate) => 文字列(NSString)に変換
    NSDate *now = [NSDate date];
    NSString *strNow = [df stringFromDate:now];
    
    // 送信したいURLを作成し、Requestを作成します。
    NSString *urlString = [NSString stringWithFormat:@"%@%@&nocache=%@", APP_VERSION_URL, APP_ID, strNow];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

    - (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    receivedData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        // HTTPリクエスト失敗処理
        buttonExec.enabled = true;
    } else {
        [self successHttpRequest];
    }
}

- (void) successHttpRequest {
        
    NSDictionary *versionSummary  = [NSJSONSerialization JSONObjectWithData:receivedData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
    
    NSDictionary *results = [[versionSummary objectForKey:@"results"] objectAtIndex:0];
    // ストアバージョン
    NSString *latestVersion = [results objectForKey:@"version"];
    // 現在のバージョン
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (![currentVersion isEqualToString:latestVersion])
    {
        if ([currentVersion compare:latestVersion] == NSOrderedAscending) {
            /* currentVersion < latestVersion */
            NSString *urlString = [NSString stringWithFormat:@"%@\n%@%@\n%@%@", @"最新バージョンが入手可能です。",
                                   @"ストアバージョン：", latestVersion,
                                   @"現在のバージョン：", currentVersion];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ"
                                                                                     message:urlString
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
           //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
           [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
           {
               NSString *urlString = [NSString stringWithFormat:@"%@%@", APP_UPDATE_URL, APP_ID];
               NSURL *url = [NSURL URLWithString:urlString];
               [[UIApplication sharedApplication] openURL:url
                                                  options:@{}
                                        completionHandler:nil];
               //ボタンがタップされた際の処理
               self->buttonExec.enabled = true;
           }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    buttonExec.enabled = _cameraGranted && _locationGranted && _bluetoothGranted;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    companyViewController = [[CompanyViewController alloc] initWithNibName:@"CompanyViewController" bundle:nil];
    [self.navigationController pushViewController:companyViewController animated:YES];
}
// 全権限確認完了後にボタン状態を決定
- (void)updateButtonState {
    BOOL allGranted = _cameraGranted && _locationGranted && _bluetoothGranted;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->buttonExec.enabled = allGranted;
        
        if (!allGranted) {
            // 拒否された権限をアラートで通知
            NSMutableArray *denied = [NSMutableArray array];
            if (!self->_cameraGranted)       [denied addObject:@"カメラ"];
            if (!self->_locationGranted)     [denied addObject:@"位置情報"];
            if (!self->_bluetoothGranted)    [denied addObject:@"Bluetooth"];
            
            NSString *message = [NSString stringWithFormat:@"以下の権限が許可されていません。設定アプリから許可してください。\n\n%@",
                                 [denied componentsJoinedByString:@"\n"]];
            
            UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"権限エラー"
                message:message
                preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"設定を開く"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *a) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
         
    });
}

// 1. カメラ権限
- (void)requestCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            self->_cameraGranted = granted;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestLocationPermission];
            });
        }];
    } else {
        _cameraGranted = (status == AVAuthorizationStatusAuthorized);
        [self requestLocationPermission];
    }
}

// 2. 位置情報権限
- (void)requestLocationPermission {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    CLAuthorizationStatus status = self.locationManager.authorizationStatus;
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        // デリゲートで次へ
    } else {
        _locationGranted = (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
                            status == kCLAuthorizationStatusAuthorizedAlways);
        [self requestBluetoothPermission];
    }
}

// CLLocationManagerDelegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = manager.authorizationStatus;
    if (status != kCLAuthorizationStatusNotDetermined) {
        _locationGranted = (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
                            status == kCLAuthorizationStatusAuthorizedAlways);
        [self requestBluetoothPermission];
    }
}

// 3. Bluetooth権限
- (void)requestBluetoothPermission {
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

// CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL granted;
    
    if (@available(iOS 13.1, *)) {
        granted = (CBCentralManager.authorization == CBManagerAuthorizationAllowedAlways);
    } else {
        granted = (central.state != CBManagerStateUnauthorized);
    }
    
    _bluetoothGranted = granted;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateButtonState];
    });
}
                   
@end
