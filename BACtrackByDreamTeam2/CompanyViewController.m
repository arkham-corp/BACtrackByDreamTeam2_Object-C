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
}
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;

@end

@implementation CompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"会社"];
    
    buttonExec.exclusiveTouch = true;
    
    numberTextField.delegate = self;
    
    // 前回値取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    numberTextField.text = [ud stringForKey:KEY_COMPANY];
    
    NSString *status = [ud stringForKey:KEY_CONECTION_STATUS];
    if([status isEqual:(@"1")]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:@"インターネットに接続できませんが。測定を続けますか？" preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            self->buttonExec.enabled = true;
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"1" forKey:KEY_CHECK_MODE];
            [ud synchronize];

         }]];

       [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
           
           self->buttonExec.enabled = false;
           
           NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
           [ud setObject:@"0" forKey:KEY_CHECK_MODE];
           [ud synchronize];
           
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    buttonExec.enabled = false;

//20231214
//    [self getApplicationApiUrl];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CHECK_MODE];

    if([status isEqual:(@"0")]) {
        
        [self getApplicationApiUrl];
        
    } else {
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
//20231214

}

- (void)getApplicationApiUrl
{
    NSString *urlString;
    
    if ([TEST_FLG isEqualToString:@"1"])
    {
        urlString = [NSString stringWithFormat: @"http://%@/%@", HTTP_TEST_HOST_NAME, HTTP_GET_API_URL];
    }
    else
    {
        urlString = [NSString stringWithFormat: @"https://%@/%@", HTTP_HOST_NAME, HTTP_GET_API_URL];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 送信内容をBODYに入れる
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    // HTTPBodyには、NSData型で設定する
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
    // 送信したいURLを作成し、Requestを作成します。
    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_GET_ALCOHOL_VALUE_DIV];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 送信内容をBODYに入れる
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    // HTTPBodyには、NSData型で設定する
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
        urlString = [NSString stringWithFormat: @"http://%@/%@", HTTP_TEST_HOST_NAME, HTTP_GET_MENU_CONTROL];
    }
    else
    {
        urlString = [NSString stringWithFormat: @"https://%@/%@", HTTP_HOST_NAME, HTTP_GET_MENU_CONTROL];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 送信内容をBODYに入れる
    NSString *companyCode = numberTextField.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"getApplicationMenuControl"];
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
        else if ([task.accessibilityLabel isEqual:@"getApplicationMenuControl"])
        {
            [self successGetApplicationMenuControl];
        }
        else
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
        [ud setObject:numberTextField.text forKey:KEY_COMPANY];
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

// データ受信が終わったら呼び出されるメソッド。
- (void) successGetAlcoholValueDiv {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    NSString *result = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // 受信したデータをUITextViewに表示する。
    if (![result isEqualToString:@""])
    {
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:result forKey:KEY_ALCOHOL_VALUE_DIV];
        [ud synchronize];
        
        // メニュー情報取得
        [self getApplicationMenuControl];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"会社情報の取得に失敗しました"
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
    
    // 受信したデータをUITextViewに表示する。
    if (result)
    {
        // データを分解
        NSArray *values = [data componentsSeparatedByString:@","];
        NSString *app_roll_call_enabled = values[0];
        NSString *app_send_list_enabled = values[1];
        NSString *app_reminder_enabled = values[2];
        
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:app_roll_call_enabled forKey:KEY_MENU_DRIVING_REPORT_ENABLED];
        [ud setObject:app_send_list_enabled forKey:KEY_MENU_SEND_LIST];
        [ud setObject:app_reminder_enabled forKey:KEY_MENU_REMINDER_ENABLED];
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

- (void)failureHttpRequest:(NSError *)error {
    // エラー情報を表示する。
    // objectForKeyで指定するKeyがポイント
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

    //下記のコードでダイアログを表示します。
    [self presentViewController:alertController animated:YES completion:nil];

    
}

@end
