//
//  MenuViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/16.
//

#import "MenuViewController.h"
#import "AppConsts.h"

@interface MenuViewController () <NSURLSessionDataDelegate>
{
    NSMutableData *receivedData;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"メニュー"];
    
    buttonInspection.exclusiveTouch = true;
    buttonDrivingReport.exclusiveTouch = true;
    buttonSendList.exclusiveTouch = true;
    buttonReminder.exclusiveTouch = true;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *app_driving_report_enabled = [ud stringForKey:KEY_MENU_DRIVING_REPORT_ENABLED];
    NSString *app_send_list_enabled = [ud stringForKey:KEY_MENU_SEND_LIST];
    NSString *app_reminder_enabled = [ud stringForKey:KEY_MENU_REMINDER_ENABLED];
    
    if (![app_driving_report_enabled isEqualToString:@"1"])
    {
        buttonDrivingReport.hidden = true;
    }
    if (![app_send_list_enabled isEqualToString:@"1"])
    {
        buttonSendList.hidden = true;
    }
    if (![app_reminder_enabled isEqualToString:@"1"])
    {
        buttonReminder.hidden = true;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    buttonInspection.enabled = true;
    buttonDrivingReport.enabled = true;
    buttonSendList.enabled = true;
    buttonReminder.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//20231211
- (void)getFreeTitle
{
    // 接続先
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
    // 送信したいURLを作成し、Requestを作成します。
    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_GET_FREE_TITLE];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 送信内容をBODYに入れる
    NSString *companyCode = [ud stringForKey: KEY_COMPANY];;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@", companyCode];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"getFreeTitle"];
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
        if ([task.accessibilityLabel isEqual:@"getFreeTitle"])
        {
            [self successGetFreeTitlel];
        }
    }
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successGetFreeTitlel {
    
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
        NSString *str1= values[0];
        NSString *str2 = values[1];
        NSString *str3 = values[2];
        
        NSString *free_title1 = [str1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *free_title2 = [str2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *free_title3 = [str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:free_title1 forKey:KEY_FREE_TITLE1];
        [ud setObject:free_title2 forKey:KEY_FREE_TITLE2];
        [ud setObject:free_title3 forKey:KEY_FREE_TITLE3];
        [ud synchronize];
        
        //運転日報に移動
        drivingReportViewController = [[DrivingReportViewController alloc] initWithNibName:@"DrivingReportViewController" bundle:nil];
        [self.navigationController pushViewController:drivingReportViewController animated:YES];
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"設定項目情報の取得に失敗しました"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続エラー"
                                                                             message:@"サーバーに接続できませんでした"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
   }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)btnInspectionTouchUpInside:(id)sender {
    buttonInspection.enabled = false;
    buttonDrivingReport.enabled = false;
    buttonSendList.enabled = false;
    buttonReminder.enabled = false;
    gpsViewController = [[GPSViewController alloc] initWithNibName:@"GPSViewController" bundle:nil];
    [self.navigationController pushViewController:gpsViewController animated:YES];
}

- (IBAction)btnDrivinngReportTouchUpInside:(id)sender {
    
    buttonInspection.enabled = false;
    buttonDrivingReport.enabled = false;
    buttonSendList.enabled = false;
    buttonReminder.enabled = false;
    
    [self getFreeTitle];
}

- (IBAction)btnSendListTouchUpInside:(id)sender {
    buttonInspection.enabled = false;
    buttonDrivingReport.enabled = false;
    buttonSendList.enabled = false;
    buttonReminder.enabled = false;
    sendListViewController = [[SendListViewController alloc] initWithNibName:@"SendListViewController" bundle:nil];
    [self.navigationController pushViewController:sendListViewController animated:YES];
}

- (IBAction)btnReminderTouchUpInside:(id)sender {
    buttonInspection.enabled = false;
    buttonDrivingReport.enabled = false;
    buttonSendList.enabled = false;
    buttonReminder.enabled = false;
    reminderViewController = [[ReminderViewController alloc] initWithNibName:@"ReminderViewController" bundle:nil];
    [self.navigationController pushViewController:reminderViewController animated:YES];
}
@end
