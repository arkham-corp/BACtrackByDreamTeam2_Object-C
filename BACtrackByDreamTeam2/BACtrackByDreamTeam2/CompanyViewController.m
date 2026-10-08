//
//  CompanyViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/11/02.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "CompanyViewController.h"
#import "AppConsts.h"

@interface CompanyViewController () <NSURLSessionDataDelegate>
{
    NSMutableData *receivedData;
    NSInteger retryCount;
}

@end

@implementation CompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"会社"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"0" forKey:KEY_CHECK_MODE];
    [ud synchronize];

}

- (void)viewWillAppear:(BOOL)animated
{
    buttonExec.enabled = true;
    buttonExec.exclusiveTouch = true;
    numberTextField.delegate = self;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    numberTextField.text = [ud stringForKey:KEY_COMPANY];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];

        if([status isEqual:(@"1")]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意"
                                                                             message:@"インターネットに接続できませんが。測定を続けますか？"
                                                                      preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self->buttonExec.enabled = true;
                [ud setObject:@"1" forKey:KEY_CHECK_MODE];
                [ud synchronize];
            }]];

            [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self->buttonExec.enabled = false;
                [ud setObject:@"0" forKey:KEY_CHECK_MODE];
                [ud synchronize];
            }]];

            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;

    if([numberTextField.text isEqual:(@"")]) {
        UIAlertController *alertController = [UIAlertController
                                            alertControllerWithTitle:@"エラー"
                                            message:@"会社コードを入力して下さい"
                                            preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           self->buttonExec.enabled = true;
       }]];
       [self presentViewController:alertController animated:YES completion:nil];

    } else {

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *status = [ud stringForKey:KEY_CHECK_MODE];

        if([status isEqual:(@"0")]) {
            
            [self getApplicationApiUrl];
        
        } else {
            // 値保存
            [ud setObject:numberTextField.text forKey:KEY_COMPANY];
            [ud setObject:@"" forKey:KEY_HTTP_URL];
            [ud setObject:@"1" forKey:KEY_ALCOHOL_VALUE_DIV];//0:血中1:呼気２:両方
            [ud synchronize];
            // GPS画面に移動
            gpsViewController = [[GPSViewController alloc] initWithNibName:@"GPSViewController" bundle:nil];
            [self.navigationController pushViewController:gpsViewController animated:YES];
        }
    }
}

- (void)getApplicationApiUrl
{
    NSString *urlString;
    if ([TEST_FLG isEqualToString:@"1"]) {
        urlString = [NSString stringWithFormat: @"http://%@/%@", HTTP_TEST_HOST_NAME, HTTP_GET_API_URL];
    } else {
        urlString = [NSString stringWithFormat: @"https://%@/%@", HTTP_HOST_NAME, HTTP_GET_API_URL];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];

    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"getApplicationApiUrl"];
    [task resume];
}

- (void)getAlcoholValueDiv
{
    // 接続先
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *http_url = [ud stringForKey:KEY_HTTP_URL];

    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_GET_SYSTEM_VALUE];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"getAlcoholValueDiv"];
    [task resume];
}

- (void)getApplicationMenuControl
{
    NSString *urlString;
    
    if ([TEST_FLG isEqualToString:@"1"])
    {
        urlString = [NSString stringWithFormat: @"http://%@/%@", HTTP_TEST_HOST_NAME, HTTP_GET_MANAGER_SYSTEM_VALUE];
    }
    else
    {
        urlString = [NSString stringWithFormat: @"https://%@/%@", HTTP_HOST_NAME, HTTP_GET_MANAGER_SYSTEM_VALUE];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"getApplicationMenuControl"];
    [task resume];
}

//HTTPリクエストのデリゲートメソッド(データ受け取り初期処理)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    receivedData = [[NSMutableData alloc] init];

    completionHandler(NSURLSessionResponseAllow);
}

//HTTPリクエストのデリゲートメソッド(受信の度に実行)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

//HTTPリクエストのデリゲートメソッド(完了処理)
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error)
    {
        // HTTPリクエスト失敗処理
        [self failureHttpRequest:error];
    }
    else
    {
        // HTTPリクエスト成功処理
        if ([task.accessibilityLabel isEqual:@"getApplicationApiUrl"])
        {
            [self successGetApplicationApiUrl];
        }
        if ([task.accessibilityLabel isEqual:@"getApplicationMenuControl"])
        {
            [self successGetApplicationMenuControl];
        }
        if ([task.accessibilityLabel isEqual:@"getAlcoholValueDiv"])
        {
            [self successGetAlcoholValueDiv];
        }
    }
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successGetApplicationApiUrl {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];

    // JSONのパースに失敗した場合は`nil`が入る
    Boolean result = false;
    NSString *data = @"";
    if (json)
    {
        result = [[json valueForKey:@"status"] boolValue];
        data = [json valueForKey:@"data"];
    }
    
    // 受信したデータをUITextViewに表示する。
    if (result)
    {
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:data forKey:KEY_HTTP_URL];
        [ud synchronize];
        [self getAlcoholValueDiv];
        
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"会社が見つかりません"
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

- (void) successGetAlcoholValueDiv {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];

    // JSONのパースに失敗した場合は`nil`が入る
    Boolean result = false;
    NSString *data = @"";
    if (json)
    {
        result = [[json valueForKey:@"status"] boolValue];
        data = [json valueForKey:@"data"];
    }
    
    if (result)
    {
        retryCount = 0;
        
        NSArray *values = [data componentsSeparatedByString:@","];
        NSString *alcohol_value_div = values[0];
        NSString *face_sim = values[1];
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:alcohol_value_div forKey:KEY_ALCOHOL_VALUE_DIV];
        [ud setObject:face_sim forKey:KEY_RECOGNITION_SIMILARITY];
        [ud synchronize];
        
        [self getApplicationMenuControl];

    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"会社情報の取得に失敗しました"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           self->buttonExec.enabled = true;
       }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // すでに別の画面が表示されていないかチェック
            if (self.presentedViewController == nil) {
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }
 }

// データ受信が終わったら呼び出されるメソッド。
- (void) successGetApplicationMenuControl {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];

    // JSONのパースに失敗した場合は`nil`が入る
    Boolean result = false;
    NSString *data = @"";
    if (json)
    {
        result = [[json valueForKey:@"status"] boolValue];
        data = [json valueForKey:@"data"];
    }
    
    if (result)
    {
        // データを分解
        NSArray *values = [data componentsSeparatedByString:@","];
        NSString *link_url = values[0];
        NSString *app_endpoint_url = values[1];
        NSString *app_roll_call_enabled = values[2];
        NSString *app_send_list_enabled = values[3];
        NSString *app_reminder_enabled = values[4];
        NSString *app_recognition_enabled = values[5];

        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:numberTextField.text forKey:KEY_COMPANY];
        [ud setObject:link_url forKey:KEY_HTTP_URL];
        [ud setObject:app_endpoint_url forKey:KEY_API_URL];
        [ud setObject:app_roll_call_enabled forKey:KEY_MENU_DRIVING_REPORT_ENABLED];
        [ud setObject:app_send_list_enabled forKey:KEY_MENU_SEND_LIST];
        [ud setObject:app_reminder_enabled forKey:KEY_MENU_REMINDER_ENABLED];
        [ud setObject:app_recognition_enabled forKey:KEY_RECOGNITION_ENABLE];
        [ud synchronize];
        
        if ([app_roll_call_enabled isEqualToString:@"1"] ||
            [app_send_list_enabled isEqualToString:@"1"] ||
            [app_reminder_enabled isEqualToString:@"1"])
        {
            // メニュー画面に移動
            menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            [self.navigationController pushViewController:menuViewController animated:YES];
        }
        else
        {
            // GPS画面に移動
            gpsViewController = [[GPSViewController alloc] initWithNibName:@"GPSViewController" bundle:nil];
            [self.navigationController pushViewController:gpsViewController animated:YES];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"メニュー情報の取得に失敗しました"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           self->buttonExec.enabled = true;
       }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // すでに別の画面が表示されていないかチェック
            if (self.presentedViewController == nil) {
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }
 }
/*
- (void)failureHttpRequest:(NSError *)error {

    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"サーバーへ接続できませんでした" message:@"通信は行わず,測定を続けますか？" preferredStyle:UIAlertControllerStyleAlert];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [ud setObject:@"1" forKey:KEY_CHECK_MODE];
            [ud synchronize];
            self->buttonExec.enabled = true;
            [self setTitle:@"会社（無通信モード）"];

    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [ud setObject:@"0" forKey:KEY_CHECK_MODE];
        [ud synchronize];
        self->buttonExec.enabled = false;
      }]];

    dispatch_async(dispatch_get_main_queue(), ^{
            // すでに別の画面が表示されていないかチェック
            if (self.presentedViewController == nil) {
                [self presentViewController:alertController animated:YES completion:nil];
            }
    });
}
*/

- (void)failureHttpRequest:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %ld", [error localizedDescription], (long)error.code);
    
    // 一時的なエラー（タイムアウトや接続ロス）かつ、リトライが5回未満の場合だけ自動リトライする
    if ((error.code == NSURLErrorTimedOut ||
         error.code == NSURLErrorNetworkConnectionLost ||
         error.code == NSURLErrorNotConnectedToInternet)
        && retryCount < 5) {
        
        retryCount++; // カウントを増やす
        NSLog(@"通信を再試行します...（%ld回目）", (long)retryCount);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->buttonExec.enabled = YES;
            [self btnDecisionTouchUpInside:nil];
        });
        return; // アラートを出さずに抜ける
    }

    // --- ここから下は、リトライしてもダメだった場合、または機内モードの場合の処理 ---
    
    // 次回の通信のためにリトライカウントをリセットしておく
    retryCount = 0;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"サーバーへ接続できませんでした"
                                                                             message:@"通信は行わず,測定を続けますか？"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [ud setObject:@"1" forKey:KEY_CHECK_MODE];
            [ud synchronize];
            self->buttonExec.enabled = true;
            [self setTitle:@"会社（無通信モード）"];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [ud setObject:@"0" forKey:KEY_CHECK_MODE];
        [ud synchronize];
        self->buttonExec.enabled = false;
    }]];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.presentedViewController == nil) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}

@end
