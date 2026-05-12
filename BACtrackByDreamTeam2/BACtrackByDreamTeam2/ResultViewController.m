//
//  ResultViewController.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/09.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import "ResultViewController.h"
#import "AppConsts.h"
#import "Realm/Realm.h"
#import "RealmLocalDataAlcoholResult.h"

@interface ResultViewController () <NSURLSessionDataDelegate>
{
    NSMutableData *receivedData;
    SystemSoundID soundID;
}

@end

@implementation ResultViewController

int retryCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    btnEnd.exclusiveTouch = true;
    [btnEnd setEnabled:false];
    retryCount = 0;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//20231214
    NSString *status = [ud stringForKey:KEY_CHECK_MODE];

    if([status isEqual:(@"0")]) {
        [self setTitle:@"測定結果"];
        [lblSending setText:@"送信中"];
    } else {
        [self setTitle:@"測定結果（無通信モード）"];
        [lblSending setText:@"無通信モード"];
    }
//20231214
    
    NSString *driving_div = [ud stringForKey:KEY_DRIVING_DIV];
    NSString *value = [ud stringForKey:KEY_ALCOHOL_VALUE];
    float alcoholValue = [value floatValue];
    float alcoholValueBreath = alcoholValue * 5;
    
    NSString *alcoholValueDiv = [ud stringForKey:KEY_ALCOHOL_VALUE_DIV];
    
    // 小数第２位に四捨五入
    alcoholValueBreath = [[NSString stringWithFormat:@"%.2f", alcoholValueBreath] floatValue];
    
    if (alcoholValueBreath != 0)
    {
        // 異常
        [lblMessage setText:@"【警告】\n現状態での運転禁止\n管理者へ報告する事"];
        [lblMessage setTextColor:[UIColor systemRedColor]];
    }
    
    if ([driving_div isEqualToString:@"1"])
    {
        lblDrivingDiv.text = @"乗務後";
    }
    else
    {
        lblDrivingDiv.text = @"乗務前";
    }
    
    if ([alcoholValueDiv isEqualToString:@"1"])
    {
        // 呼気を画面に表示
        lblTitle.text = @"測定結果(呼気)";
        lblResult.text = [NSString stringWithFormat:@"%.2f%@", alcoholValueBreath, @"mg/L"];
    }
    else if ([alcoholValueDiv isEqualToString:@"2"])
    {
        // 呼気を画面に表示
        lblTitle.text = @"呼気中濃度表示(呼気)";
        lblResult.text = [NSString stringWithFormat:@"%.2f%@", alcoholValueBreath, @"mg/L"];
    }
    else
    {
        // 血中を画面に表示
        lblTitle.text = @"測定結果(血中)";
        lblResult.text = [NSString stringWithFormat:@"%.2f%@", alcoholValue, @"%"];
    }
        
    // アルコール消化予定時刻計算
    float remain = alcoholValue / ALCHOL_REMOVEAL_RATE;
    float remain_h = floorf(alcoholValue / ALCHOL_REMOVEAL_RATE);
    float remain_m = roundf((remain - remain_h) * 60);
    
    // 現在時刻に残留時間を足す
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.hour = remain_h;
    comp.minute = remain_m;
    
    NSDate *resultDate = [calendar dateByAddingComponents:comp toDate:now options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *result = [formatter stringFromDate:resultDate];
    
    [lblRemoval setText:[NSString stringWithFormat:@"%@ です", result]];
    
//20231214
    [ud setObject:@"0" forKey:KEY_SEND_FLG];
    [ud synchronize];

    if([status isEqual:(@"0")]) {
        
        [self sendData];
        
    } else {
        [btnEnd setEnabled:true];
    }
    [self SaveData];
//20231214

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

- (void)sendData {
    
    // 送信内容を stringsBody に入れる
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *companyCode = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_COMPANY]];
    NSString *inspectionTime = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_INSPECTION_TIME]];
    NSString *driverCode = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_DRIVER]];
    NSString *carNo = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_CAR_NO]];
    NSString *locationName = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_ADDRESS]];
    NSString *locationLat = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_LATITUDE]];
    NSString *locationLong = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_LONGITUDE]];
    NSString *alcoholValue = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_ALCOHOL_VALUE]];
    NSString *bactrackId = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_BREATHALYZER_UUID]];
    NSString *useCount = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_BREATHALYZER_USE_COUNT]];
    NSString *drivingDiv = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_DRIVING_DIV]];
    NSData *photoData = [ud dataForKey:KEY_PHOTO];
    
    // 接続先
    NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
    // URL を設定し、NSMutableURLRequest を作成
    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_WRITE_ALCOHOL_VALUE];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:5];
    
    // body を初期化し、boundary を指定
    NSMutableData *body = [[NSMutableData alloc] init];
    NSString *boundary = [NSString stringWithFormat:@"---------------------------%d", arc4random() %
                          10000000];
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    // CompanyCode
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"CompanyCode\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", companyCode] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // InspectionTime
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"InspectionTime\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", inspectionTime] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // EmployeeCode
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"DriverCode\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", driverCode] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // MachineNumber
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"CarNo\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", carNo] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // LocationName
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"LocationName\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", locationName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // LocationLat
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"LocationLat\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", locationLat] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // LocationLong
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"LocationLong\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", locationLong] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // AlcoholValue
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"AlcoholValue\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", alcoholValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // BACtrackId
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"BACtrackId\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", bactrackId] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // UseCount
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"UseCount\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", useCount] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // DrivingDiv
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"DrivingDiv\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", drivingDiv] dataUsingEncoding:NSUTF8StringEncoding]];
        
    // photoData を name=photo として image/jpeg で body に appendData する
    if (photoData != nil)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"Photo\"; filename=\"Photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream; charset=ISO-8859-1\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:photoData];
    }
    // 末尾
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
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
        [self failureHttpRequest:error];
    } else {
        // HTTPリクエスト成功処理
        [self successHttpRequest];
    }
}

- (void) failureHttpRequest:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。\n再送信します。" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self resendData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successHttpRequest {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    NSString* trim = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 受信したデータをUITextViewに表示する。
    if ([trim isEqualToString:@"OK"])
    {
        [lblSending setText:@"送信成功"];
        [lblSending setTextColor:[UIColor systemGreenColor]];
//20231214
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"2" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self UpdateSendKey];
//20231214
        [btnEnd setEnabled:true];
    }
    else if ([trim isEqualToString:@"KEY_NG"])
    {
        [lblSending setText:@"送信済みです"];
        [lblSending setTextColor:[UIColor systemRedColor]];
//20231214
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"2" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self UpdateSendKey];
//20231214
        [btnEnd setEnabled:true];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。\n再送信します。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            [self resendData];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // エラー情報を表示する。
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。\n再送信します。" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self resendData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resendData {
    
    retryCount = retryCount + 1;
    
    if (2 <= retryCount) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。\nアプリを終了し初めからやりなおしてください。または管理者様へお知らせください。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            [self->btnEnd setEnabled:true];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [lblSending setText:@"送信失敗"];
        [lblSending setTextColor:[UIColor systemRedColor]];
//20231214
        // 値保存
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"0" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self UpdateSendKey];
//20231214

    } else {
        //[self performSelector:@selector(sendData) withObject:nil afterDelay:60.0];
        [self sendData];
    }
}

- (IBAction)btnEndTouchUpInside:(id)sender {
    exit(0);
}

//2023/12/15
- (void)SaveData
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RealmLocalDataAlcoholResult *alcoholResult;
    
    [realm beginWriteTransaction];
    
    alcoholResult = [[RealmLocalDataAlcoholResult alloc] init];
        
    int nextId = 1;
        
    NSNumber *maxId = [[RealmLocalDataAlcoholResult allObjectsInRealm:realm] maxOfProperty:@"_id"];
    if (maxId != nil)
    {
        nextId = [maxId intValue] + 1;
    }

    // 値セット
    alcoholResult._id = nextId;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSString stringWithFormat:@"%d", nextId] forKey:KEY_TARGET_ID];
    [ud synchronize];
    
    alcoholResult.company_code = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_COMPANY]];
    alcoholResult.inspection_time = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_INSPECTION_TIME]];
    alcoholResult.inspection_ymd = @"";
    alcoholResult.inspection_hm = @"";

    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *date = [df dateFromString:alcoholResult.inspection_time];

//    NSDateFormatter *df1 =[[NSDateFormatter alloc] init];
//    [df1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    alcoholResult.inspection_ymd = [df stringFromDate:date];
    
//    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
//    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"HHmm"];
    alcoholResult.inspection_hm = [df stringFromDate:date];
        
    NSString *alcohol =  [ud stringForKey:KEY_ALCOHOL_VALUE];
    alcoholResult.alcohol_value = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_ALCOHOL_VALUE]];

    alcoholResult.blood_alcohol_value = @"0";
    alcoholResult.breath_alcohol_Value = @"0";
    double breath =[alcohol doubleValue] * 5;
    
    NSString *div = [ud stringForKey:KEY_ALCOHOL_VALUE_DIV];
    if ([div isEqualToString:@"1"])
    {
        //呼気
        alcoholResult.breath_alcohol_Value = [NSString stringWithFormat:@"%.2f",breath];
    }
    else if ([div isEqualToString:@"2"])
    {
        //両方 呼気
        alcoholResult.breath_alcohol_Value = [NSString stringWithFormat:@"%.2f",breath];
        //血中
        alcoholResult.blood_alcohol_value = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_ALCOHOL_VALUE]];
    }
    else
    {
        //血中
        alcoholResult.blood_alcohol_value = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_ALCOHOL_VALUE]];
    }

    alcoholResult.driver_code = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_DRIVER]];
    alcoholResult.car_number = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_CAR_NO]];
    alcoholResult.location_name = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_ADDRESS]];
    alcoholResult.location_lat = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_LATITUDE]];
    if ([alcoholResult.location_lat  isEqualToString:@""])
    {
        alcoholResult.location_lat = @"0";
    }
    alcoholResult.location_long = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_LOCATION_LONGITUDE]];
    if ([alcoholResult.location_long  isEqualToString:@""])
    {
        alcoholResult.location_long = @"0";
    }
    alcoholResult.backtrack_id = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_BREATHALYZER_UUID]];
    if ([alcoholResult.backtrack_id  isEqualToString:@"0"])
    {
        alcoholResult.backtrack_id = @"";
    }
    alcoholResult.use_Number = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_BREATHALYZER_USE_COUNT]];
    alcoholResult.photo_file  = [ud dataForKey:KEY_PHOTO];
    alcoholResult.send_flg = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_SEND_FLG]];
    alcoholResult.driving_div = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_DRIVING_DIV]];

    [realm addObject:alcoholResult];
    [realm commitWriteTransaction];

    
    // 過去データ削除
    [realm beginWriteTransaction];

    NSDate *deleteDate = [NSDate dateWithTimeIntervalSinceNow:(-7)*24*60*60];
    [df setDateFormat:@"yyyyMMdd"];
    NSString *strDeleteDate = [df stringFromDate:deleteDate];
    
    NSString *company = [ud stringForKey:KEY_COMPANY];
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"company_code=%@", company];
    RLMResults *alcoholResultList = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    for (RealmLocalDataAlcoholResult *result in alcoholResultList)
    {
        
        NSString *start_ymd = alcoholResult.inspection_ymd;
        if ([start_ymd compare:strDeleteDate] != NSOrderedDescending)
        {
            [realm deleteObject:result];
        }
        
    }
    
    [realm commitWriteTransaction];

}

- (void)UpdateSendKey
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    int targetId = [[ud stringForKey:KEY_TARGET_ID] intValue];
    
    NSPredicate *preparedAlcoholResult = [NSPredicate predicateWithFormat:@"_id=%d", targetId];
    RLMResults *drivingReportList = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedAlcoholResult];
    
    if (drivingReportList.count != 0)
    {
        RealmLocalDataAlcoholResult *alcoholResult;
        
        [realm beginWriteTransaction];
        
        alcoholResult = drivingReportList[0];
        
        alcoholResult.send_flg = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_SEND_FLG]];
        
        [realm addObject:alcoholResult];
        
        [realm commitWriteTransaction];
    }
}

@end
