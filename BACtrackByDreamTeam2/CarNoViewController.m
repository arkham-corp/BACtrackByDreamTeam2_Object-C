//
//  CarNoViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "CarNoViewController.h"
#import "AppConsts.h"

@interface CarNoViewController () <NSURLSessionDataDelegate>
{
    NSMutableData *receivedData;
}
@end

@implementation CarNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//20231214
    NSString *status = [ud stringForKey:KEY_CHECK_MODE];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"車番"];
    } else {
        [self setTitle:@"車番（無通信モード）"];
    }
//20231214
    
    buttonExec.exclusiveTouch = true;
    
    numberTextField.delegate = self;
    
    // 前回値取得
    numberTextField.text = [ud stringForKey:KEY_CAR_NO];
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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *status = [ud stringForKey:KEY_CHECK_MODE];

    if([status isEqual:(@"0")]) {
        // 接続先
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
        // 送信したいURLを作成し、Requestを作成します。
        NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_CAR_NO_CHECK];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"POST";

        // 送信内容をBODYに入れる
        NSString *companyCode = [ud stringForKey:KEY_COMPANY];
        NSString *driverCode = [ud stringForKey:KEY_DRIVER];
        NSString *carNo = numberTextField.text;
        NSString *body = [NSString stringWithFormat:@"CompanyCode=%@&CarNo=%@&DriverCode=%@", companyCode, carNo, driverCode];

        // HTTPBodyには、NSData型で設定する
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];

        // HTTPリクエスト
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        [task resume];
        
    } else {
        if([numberTextField.text isEqual:(@"")]) {
            UIAlertController *alertController = [UIAlertController
                                                alertControllerWithTitle:@"エラー"
                                                message:@"車番を入力して下さい"
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
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:numberTextField.text forKey:KEY_CAR_NO];
            [ud synchronize];
            
            // 移動
            inspectionViewController = [[InspectionViewController alloc] initWithNibName:@"InspectionViewController" bundle:nil];
            [self.navigationController pushViewController:inspectionViewController animated:YES];
        }
        
    }
//20231214
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
        [self failureHttpRequest:error];
    } else {
        // HTTPリクエスト成功処理
        [self successHttpRequest];
    }
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successHttpRequest {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    // 受信したデータをUITextViewに表示する。
    if ([html hasPrefix:@"OK"])
    {
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:numberTextField.text forKey:KEY_CAR_NO];
        [ud synchronize];
        
        // 移動
        inspectionViewController = [[InspectionViewController alloc] initWithNibName:@"InspectionViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"車番が登録されていません"
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
        [self setTitle:@"車番（無通信モード）"];

     }]];

   [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       [ud setObject:@"0" forKey:KEY_CHECK_MODE];
       [ud synchronize];
       self->buttonExec.enabled = false;
     }]];

   [self presentViewController:alertController animated:YES completion:nil];
    
    
}

@end
