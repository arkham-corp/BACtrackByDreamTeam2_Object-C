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

    Boolean result = false;
    NSString *data = @"";
    if (json)
    {
        result = [[json valueForKey:@"status"] boolValue];
        data = [json valueForKey:@"data"];
    }
    
    if (result)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        // データを分解
        NSArray *values = [data componentsSeparatedByString:@","];
        NSString *str= values[0];
        //trim
        NSString *free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ud setObject:free forKey:KEY_FREE_TITLE1];
        
        str= values[1];
        free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ud setObject:free forKey:KEY_FREE_TITLE2];
        
        str= values[2];
        free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ud setObject:free forKey:KEY_FREE_TITLE3];
        
//NSLog(@"count = %lu",(unsigned long)values.count);
        if(values.count > 4) {
            //フリー項目数を８に変更対応
            str= values[3];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_TITLE4];
            
            str= values[4];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_TITLE5];
            
            str= values[5];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_TITLE6];
            
            str= values[6];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_TITLE7];
            
            str= values[7];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_TITLE8];
            
            //0:text 1:checkbox
            str= values[8];
            free = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION1];
            
            free = [values[9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION2];
            
            free = [values[10] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION3];
            
            free = [values[11] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION4];
            
            free = [values[12] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION5];
            
            free = [values[13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION6];
            
            free = [values[14] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION7];
            
            free = [values[15] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_DIVISION8];
            //0:必須でない　1:必須
            free = [values[16] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE1];
            
            free = [values[17] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE2];
            
            free = [values[18] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE3];
            
            free = [values[19] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE4];
            
            free = [values[20] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE5];
            
            free = [values[21] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE6];
            
            free = [values[22] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE7];
            
            free = [values[23] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [ud setObject:free forKey:KEY_FREE_REQUIRE8];
            
        } else {
            //フリー項目数３対応だった場合の初期化
            free = @"";
            [ud setObject:free forKey:KEY_FREE_TITLE4];
            [ud setObject:free forKey:KEY_FREE_TITLE5];
            [ud setObject:free forKey:KEY_FREE_TITLE6];
            [ud setObject:free forKey:KEY_FREE_TITLE7];
            [ud setObject:free forKey:KEY_FREE_TITLE8];
            free = @"0";
            [ud setObject:free forKey:KEY_FREE_DIVISION1];
            [ud setObject:free forKey:KEY_FREE_DIVISION2];
            [ud setObject:free forKey:KEY_FREE_DIVISION3];
            [ud setObject:free forKey:KEY_FREE_DIVISION4];
            [ud setObject:free forKey:KEY_FREE_DIVISION5];
            [ud setObject:free forKey:KEY_FREE_DIVISION6];
            [ud setObject:free forKey:KEY_FREE_DIVISION7];
            [ud setObject:free forKey:KEY_FREE_DIVISION8];
            [ud setObject:free forKey:KEY_FREE_REQUIRE1];
            [ud setObject:free forKey:KEY_FREE_REQUIRE2];
            [ud setObject:free forKey:KEY_FREE_REQUIRE3];
            [ud setObject:free forKey:KEY_FREE_REQUIRE4];
            [ud setObject:free forKey:KEY_FREE_REQUIRE5];
            [ud setObject:free forKey:KEY_FREE_REQUIRE6];
            [ud setObject:free forKey:KEY_FREE_REQUIRE7];
            [ud setObject:free forKey:KEY_FREE_REQUIRE8];
        }

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
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続エラー"
                                                                             message:@"サーバーに接続できませんでした"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
   }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

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
