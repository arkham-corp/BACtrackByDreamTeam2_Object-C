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
    
    buttonExec.exclusiveTouch = true;
    buttonExec.enabled = false;
    
    // 利用規約判定
    if (![agreement isEqualToString:@"1"])
    {
        AgreementViewController *agreementViewController = [[AgreementViewController alloc] init];
        [self presentViewController:agreementViewController animated:YES completion:nil];
    }
        
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined)
    {
        // アプリで初めてカメラ機能を使用する場合
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
        {
              if (granted)
              {
                  // 使用が許可された場合
              }
              else
              {
                  self->buttonExec.enabled = false;
              }
        }];
    }
    
    [self versionCeck];
    
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

/**
 * HTTPリクエストのデリゲートメソッド(データ受け取り初期処理)
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 保持していたレスポンスのデータを初期化
    receivedData = [[NSMutableData alloc] init];

    // didReceivedData と didCompleteWithError が呼ばれるように、通常継続の定数をハンドラーに渡す
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * HTTPリクエストのデリゲートメソッド(受信の度に実行)
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 1つのパケットに収まらないデータ量の場合は複数回呼ばれるので、データを追加していく
    [receivedData appendData:data];
}

/**
 * HTTPリクエストのデリゲートメソッド(完了処理)
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        // HTTPリクエスト失敗処理
        buttonExec.enabled = true;
    } else {
        // HTTPリクエスト成功処理
        [self successHttpRequest];
    }
}

// データ受信が終わったら呼び出されるメソッド。
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

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;
    companyViewController = [[CompanyViewController alloc] initWithNibName:@"CompanyViewController" bundle:nil];
    [self.navigationController pushViewController:companyViewController animated:YES];
}

@end
