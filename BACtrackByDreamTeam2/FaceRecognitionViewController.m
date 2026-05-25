//
//  FaceRecognitionViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2026/03/25.
//  Copyright © 2026年 COM-MAC. All rights reserved.
//

#import "FaceRecognitionViewController.h"
#import "AppConsts.h"

@implementation FaceRecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // デバイスのスリープタイマーを無効化
    UIApplication* application = [UIApplication sharedApplication];
    application.idleTimerDisabled = YES;
}

// メソッドを実装
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // キーボードを閉じる
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setTitle:@"顔認証"];
    numberTextField.delegate = self;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    numberTextField.text = [ud stringForKey:KEY_DRIVER];
    tvDriver.text = @"";
    tvMessage.text = @"コードを入力してください";

    UIFont *font = [UIFont systemFontOfSize: 20];
    [numberTextField setFont:font];
    [tvDriver setFont:font];

    font = [UIFont systemFontOfSize:18];
    [tvMessage setFont:font];
    tvMessage.textAlignment = NSTextAlignmentCenter;
    
    buttonExecute.enabled = YES;
}

// 顔検出後の撮影完了コールバック

- (void)cameraManagerDidCapturePhoto:(UIImage *)image {
    // base64に変換して保存
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:base64 forKey:KEY_PHOTO];
    [ud synchronize];

    [self.cameraManager stopCamera];
    tvMessage.text = @"認証中...";
    [self faceRecognition];
}


// タイムアウトコールバック
- (void)cameraManagerDidTimeout {
    buttonExecute.enabled = YES;

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"タイムアウト"
        message:@"顔を検出できませんでした。もう一度やり直してください。"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *a) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 権限なしコールバック

- (void)cameraManagerDidDenied {
    buttonExecute.enabled = YES;
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"エラー"
        message:@"カメラの利用が許可されていません。設定アプリから許可してください。"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnDecisionTouchUpInside:(id)sender {
    if([numberTextField.text isEqual:(@"")]) {
        UIAlertController *alertController = [UIAlertController
                                            alertControllerWithTitle:@"エラー"
                                            message:@"運転者を入力して下さい"
                                            preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
       }]];
       [self presentViewController:alertController animated:YES completion:nil];

    } else {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *status = [ud stringForKey:KEY_CHECK_MODE];
        
        if([status isEqual:(@"0")]) {
            buttonExecute.enabled = NO;
            // CameraManager 初期化
            self.cameraManager = [[CameraManager alloc] init];
            self.cameraManager.delegate = self;
            self.cameraManager.previewView = imageView;
            self.cameraManager.useFaceDetection = YES;
            self.cameraManager.timeoutSeconds = 30;

            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_GET_DRIVER];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            
            NSString *companyCode = [ud stringForKey:KEY_COMPANY];
            NSString *driverCode = numberTextField.text;
            NSString *body = [NSString stringWithFormat:@"CompanyCode=%@&DriverCode=%@", companyCode, driverCode];
            request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
            
            /// HTTPリクエスト
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                  delegate:self
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
            [task setAccessibilityLabel:@"DriverCeck"];
            [task resume];
            
            
        } else {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:numberTextField.text forKey:KEY_DRIVER];
            [ud synchronize];
            // 移動
            carNoViewController = [[CarNoViewController alloc] initWithNibName:@"CarNoViewController" bundle:nil];
            [self.navigationController pushViewController:carNoViewController animated:YES];
            
        }
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.cameraManager stopCamera];
    // デバイスのスリープタイマーを有効化します。
    UIApplication* application = [UIApplication sharedApplication];
    application.idleTimerDisabled = NO;
}
    
- (void)faceRecognition
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *api_url = [ud stringForKey:KEY_API_URL];
    
    NSURL *url = [NSURL URLWithString:api_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *params = @{
        @"image": [ud stringForKey:KEY_PHOTO] ?: @"",
        @"companyCode": [ud stringForKey:KEY_COMPANY] ?: @"",
        @"employeeId": [ud stringForKey:KEY_DRIVER] ?: @"",
        @"similarityThreshold": [ud stringForKey:KEY_RECOGNITION_SIMILARITY] ?: @"95.0"
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    request.HTTPBody = jsonData;

    // HTTPリクエスト実行
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"faceRecognition"];
    [task resume];

}

 // HTTPリクエストのデリゲートメソッド(データ受け取り初期処理)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    receivedData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

 // HTTPリクエストのデリゲートメソッド(受信の度に実行)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

//  HTTPリクエストのデリゲートメソッド(完了処理)
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    if (error)
    {
        // HTTPリクエスト失敗処理
        [self failureHttpRequest:error];
    }
    else
    {
        // HTTPリクエスト成功処理
        if ([task.accessibilityLabel isEqual:@"faceRecognition"])
        {
            [self successFaceRecognition];
        } else {
            [self successDriverCheck];
        }
    }
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successFaceRecognition {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];

    tvMessage.text = @"";
    NSString *message = @"";
    NSString *result = @"";
    NSString *errormsg = @"";
    if (json)
    {
        message = [json valueForKey:@"message"];
        result = [json valueForKey:@"result"];
        errormsg = [json valueForKey:@"error"];
    }
    
    if ([message containsString:@"Successfully"])
    {
        if([result isEqual:(@"OK")])
        {
            // 遷移前にカメラを完全に停止させる
            [self.cameraManager stopCamera];
            dispatch_async(dispatch_get_main_queue(), ^{
                // プレビューを消す
                for (CALayer *layer in [self->imageView.layer.sublayers copy]) {
                    if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                        [layer removeFromSuperlayer];
                    }
                }
                
                // 画面遷移
                CarNoViewController *nextVC = [[CarNoViewController alloc] initWithNibName:@"CarNoViewController" bundle:nil];
                [self.navigationController pushViewController:nextVC animated:YES];
            });

            //顔認証画面には戻れないようにする
            /*
            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
            [navigationArray removeObject:self];
            self.navigationController.viewControllers = navigationArray;
            */
            
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"顔認証に失敗しました" message:@"再度認証を行います？" preferredStyle:UIAlertControllerStyleAlert];
           
            [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                // アラートが消えるのを待ってからカメラを再起動する
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self reloadScreen];
                    self->buttonExecute.enabled = YES;
                });
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.cameraManager stopCamera];
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];

        }

    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"顔認証に失敗しました" message:@"再度認証を行います？" preferredStyle:UIAlertControllerStyleAlert];

        if ([errormsg isKindOfClass:[NSString class]]) {
            if ([errormsg containsString:@"No faces"]) {
                alertController = [UIAlertController alertControllerWithTitle:@"画像に対象が見つけられませんでした" message:@"再度認証を行います？" preferredStyle:UIAlertControllerStyleAlert];
            }
            if ([errormsg containsString:@"Taget user not found"]){
                 alertController = [UIAlertController alertControllerWithTitle:@"認証元の画像が登録されていません" message:@"再度認証を行います？" preferredStyle:UIAlertControllerStyleAlert];
            }
            if ([errormsg containsString:@"match was for a different"]){
                 alertController = [UIAlertController alertControllerWithTitle:@"画像は他運転手で登録されています" message:@"再度認証を行います？" preferredStyle:UIAlertControllerStyleAlert];
            }

        } else {
            //NSString *errorStr = [errormsg description];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // アラートが消えるのを待ってからカメラを再起動する
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadScreen];
                self->buttonExecute.enabled = YES;
                self->tvMessage.text = @"顔を枠に収めてください";
            });
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

    }

 }

- (void)reloadScreen {
    // 以前保存した写真は消去
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:KEY_PHOTO];
    [ud synchronize];

    [self.cameraManager startCamera];
}

- (void)failureHttpRequest:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                             message:@"顔認証に失敗しました"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
    {
        self->buttonExecute.enabled = YES;

        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showToast:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];

    // 1秒後に自動で閉じる
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void) successDriverCheck {
        
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
        NSArray *values = [data componentsSeparatedByString:@","];
        NSString *face_ng = values[0];
        NSString *driver_name = values[2];
//        NSLog(@"successDriverCheck 3: face_ng=%@ buttonEnabled=%d", face_ng, buttonExec.enabled);

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:numberTextField.text forKey:KEY_DRIVER];
        [ud setObject:face_ng forKey:KEY_DRIVER_RECOGNITION_ENABLE];
        [ud synchronize];
        
        //運転手設定で顔認証を行わない
        if([face_ng isEqual:(@"0")]) {
            driver_name = [NSString stringWithFormat:@"%@%@", @"(顔認証なし)", driver_name];
            tvDriver.text = driver_name;
            carNoViewController = [[CarNoViewController alloc] initWithNibName:@"CarNoViewController" bundle:nil];
            [self.navigationController pushViewController:carNoViewController animated:YES];
            [self showToast:driver_name];

        } else {
            //　写真撮影から顔認証を実行　自動検出モードを起動する
            self->tvMessage.text = @"顔を枠に収めてください";
            tvDriver.text = driver_name;
            [self.cameraManager startCamera];
        }
    }
    else
    {
        buttonExecute.enabled = YES;

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"運転手情報の取得に失敗しました"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
       }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // すでに別の画面が表示されていないかチェック
            if (self.presentedViewController == nil) {
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }
    
}

@end
