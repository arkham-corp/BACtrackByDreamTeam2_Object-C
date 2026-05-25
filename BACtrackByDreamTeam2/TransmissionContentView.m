//
//  TransmissionContentView.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/15.
//

#import "AppConsts.h"
#import "TransmissionContentView.h"
#import "Realm/Realm.h"
#import "RealmLocalDataAlcoholResult.h"


@interface TransmissionContentView () <NSURLSessionDataDelegate>
{
    RealmLocalDataAlcoholResult *alcoholResult;
    
    NSMutableData *receivedData;
    int retryCount;
}
@end

@implementation TransmissionContentView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"送信内容"];
    
    buttonSend.exclusiveTouch = true;
    
    textDriverCode.delegate = self;
    textCarNumber.delegate = self;
    textInspectionTime.delegate = self;
    textInspectionYmd.delegate = self;
    textInspectionHm.delegate = self;
    textLocationName.delegate = self;
    textLocationLat.delegate = self;
    textLocationLong.delegate = self;
    textDrivingDiv.delegate = self;
    textAlcoholValue.delegate = self;
    textBacktrackId.delegate = self;
    textUseNumber.delegate = self;
    textSendFlg.delegate = self;
    
    [scrollView addSubview:contentsView];
    
    // データ取得
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *preparedSendList = [NSPredicate predicateWithFormat:@"_id=%d", self._id];
    RLMResults *result = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedSendList];
    
    if (result.count != 0)
    {
        alcoholResult = result[0];
        
        // データセット

        if ([alcoholResult.inspection_ymd length]>=6)
        {
            NSString *yy = [alcoholResult.inspection_ymd substringWithRange:NSMakeRange(0, 4)];
            NSString *mm = [alcoholResult.inspection_ymd substringWithRange:NSMakeRange(4, 2)];
            NSString *dd = [alcoholResult.inspection_ymd substringWithRange:NSMakeRange(6, 2)];
            textInspectionYmd.text = [NSString stringWithFormat:@"%@/%@/%@",yy,mm,dd];
        } else {
            textInspectionYmd.text = @"";
        }
        if ([alcoholResult.inspection_hm length]>=4)
        {
            NSString *hh = [alcoholResult.inspection_hm substringWithRange:NSMakeRange(0, 2)];
            NSString *MM = [alcoholResult.inspection_hm substringWithRange:NSMakeRange(2, 2)];
            textInspectionHm.text = [NSString stringWithFormat:@"%@:%@",hh,MM];
        } else {
            textInspectionHm.text = @"";
        }

        textInspectionTime.text = alcoholResult.inspection_time;
        textDriverCode.text = alcoholResult.driver_code;
        textCarNumber.text = alcoholResult.car_number;
        textLocation.text = alcoholResult.location_name;
        textLocationName.text = alcoholResult.location_name;
        textLocationLat.text = alcoholResult.location_lat;
        textLocationLong.text = alcoholResult.location_long;
        if ([alcoholResult.driving_div isEqualToString:@"1"])
        {
            textDrivingDiv.text = @"乗務後";
        } else {
            textDrivingDiv.text = @"乗務前";
        }
        
        //textAlcoholValue.text = alcoholResult.alcohol_value;

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
       
        NSString *div = [ud stringForKey:KEY_ALCOHOL_VALUE_DIV];
        
        if ([div isEqualToString:@"1"])
        {
            //呼気
            double value = [alcoholResult.breath_alcohol_Value doubleValue];
            textAlcoholValue.text = [NSString stringWithFormat:@"%.2fmg/L",value];
        }
        else if ([div isEqualToString:@"2"])
        {
            //呼気
            double value = [alcoholResult.breath_alcohol_Value doubleValue];
            textAlcoholValue.text = [NSString stringWithFormat:@"%.2fmg/L",value];
        }
        else
        {
            //血中
            double value = [alcoholResult.blood_alcohol_value doubleValue];
            textAlcoholValue.text = [NSString stringWithFormat:@"%.2f%%", value];
        }
        
        textBacktrackId.text = alcoholResult.backtrack_id;
        textUseNumber.text = alcoholResult.use_Number;
        
        buttonSend.enabled = false;

        if ([alcoholResult.send_flg isEqualToString:@"0"])
        {
            textSendFlg.text = @"未送信";
            buttonSend.enabled = true;

        } else if([alcoholResult.send_flg isEqualToString:@"1"]) {
            textSendFlg.text = @"送信NG";
            buttonSend.enabled = true;
        } else {
            textSendFlg.text = @"送信済";
        }

        UIImage* resultImage = [[UIImage alloc] initWithData:alcoholResult.photo_file];
        imageView.image = resultImage;
        

    } else {
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self setControlEnable];

}

- (void)setControlEnable
{
    buttonSend.enabled = true;
    
    textInspectionYmd.enabled = false;
    textInspectionHm.enabled = false;
    textInspectionTime.enabled = false;
    textDriverCode.enabled = false;
    textCarNumber.enabled = false;
    textLocationName.enabled = false;
    textLocationLat.enabled = false;
    textLocationLong.enabled = false;
    textDrivingDiv.enabled = false;
    textAlcoholValue.enabled = false;
    textUseNumber.enabled = false;
    textBacktrackId.enabled = false;
    textSendFlg.enabled = false;
    
    if (alcoholResult == nil)
    {
        buttonSend.enabled = false;
    }
    else
    {
        if ([alcoholResult.send_flg isEqualToString:@"2"])
        {
            
            buttonSend.enabled = false;

        }
    }

}

- (NSString *)formatDateString:(NSString *)value
{
    if ([value isEqualToString:@""])
    {
        return @"";
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    NSDate *date = [df dateFromString:value];
    
    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df2 setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [df2 stringFromDate:date];
    
    return strDate;
}

- (NSDate *)formatDate:(NSString *)value
{
    if ([value isEqualToString:@""])
    {
        return nil;
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    NSDate *date = [df dateFromString:value];
    
    return date;
}

- (NSString *)formatTimeString:(NSString *)value
{
    if ([value isEqualToString:@""])
    {
        return @"";
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"HHmm"];
    NSDate *date = [df dateFromString:value];
    
    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df2 setDateFormat:@"HH:mm"];
    NSString *strDate = [df2 stringFromDate:date];
    
    return strDate;
}

- (NSDate *)formatTime:(NSString *)value
{
    if ([value isEqualToString:@""])
    {
        return nil;
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"HHmm"];
    NSDate *date = [df dateFromString:value];
    
    return date;
}

- (void)viewDidLayoutSubviews {
    [contentsView setFrame:CGRectMake(0, 0, scrollView.frame.size.width, contentsView.frame.size.height)];
    CGSize contentsSize = CGSizeMake(scrollView.frame.size.width, contentsView.frame.size.height);
    [scrollView setContentSize:contentsSize];
    [scrollView flashScrollIndicators];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)isNumeric:(NSString *) target
{
    NSString *value = [target stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSRange match = [value rangeOfString:@"^[0-9]+$" options:NSRegularExpressionSearch];
    //数値の場合
    if(match.location != NSNotFound) {
        return true;
    }
    //数値でない場合
    else {
        return false;
    }
}

// 日付文字列のチェック関数
- (BOOL)isValidDate:(NSString *)dateString {
    // NSDateFormatterのインスタンスを生成
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 日付のフォーマットを設定
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    // 解析を厳密に行うかどうかを設定（オプション）
    [dateFormatter setLenient:NO];
    
    // 日付文字列をNSDate型に変換を試みる
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    // dateがnilでなければ日付文字列が有効な日付であると判断
    if (date) {
        return YES;
    } else {
        return NO;
    }
}

// 時間文字列のチェック関数
- (BOOL)isValidTime:(NSString *)dateString {
    // NSDateFormatterのインスタンスを生成
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 日付のフォーマットを設定
    [dateFormatter setDateFormat:@"HH:mm"];
    // 解析を厳密に行うかどうかを設定（オプション）
    [dateFormatter setLenient:NO];
    
    // 日付文字列をNSDate型に変換を試みる
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    // dateがnilでなければ日付文字列が有効な日付であると判断
    if (date) {
        return YES;
    } else {
        return NO;
    }
}

 - (IBAction)buttonSendTouchUpInside:(id)sender {
     buttonSend.enabled = false;
          
//     [self getApplicationApiUrl];
     [self sendData];
     
     buttonSend.enabled = true;
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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_COMPANY]];
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
    NSString *companyCode = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_COMPANY]];
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

- (void)checkDriver
{
    // 接続先
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
    // 送信したいURLを作成し、Requestを作成します。
    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_DRIVER_CHECK];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 送信内容をBODYに入れる
    NSString *companyCode = [ud stringForKey:KEY_COMPANY];
    NSString *driverCode = textDriverCode.text;

    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@&DriverCode=%@", companyCode, driverCode];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    /// HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"checkDriver"];
    [task resume];
    
}

- (void)checkCarNo
{
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
    NSString *carNo = textCarNumber.text;
    NSString *driverCode = textDriverCode.text;
    NSString *body = [NSString stringWithFormat:@"CompanyCode=%@&CarNo=%@&DriverCode=%@", companyCode, carNo, driverCode];

    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];

    // HTTPリクエスト
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task setAccessibilityLabel:@"checkCarNo"];
    [task resume];
}

- (void)sendData {
    
    // データ取得
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *preparedSendList = [NSPredicate predicateWithFormat:@"_id=%d", self._id];
    RLMResults *result = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedSendList];
    
    if (result.count != 0)
    {
        alcoholResult = result[0];
    }
    // 送信内容を stringsBody に入れる
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *companyCode = [NSString stringWithFormat:@"%@", [ud stringForKey:KEY_COMPANY]];
    NSString *inspectionTime = [NSString stringWithFormat:@"%@", alcoholResult.inspection_time];
    NSString *driverCode = [NSString stringWithFormat:@"%@", alcoholResult.driver_code];
    NSString *carNo = [NSString stringWithFormat:@"%@", alcoholResult.car_number];
    NSString *locationName = [NSString stringWithFormat:@"%@", alcoholResult.location_name];
    NSString *locationLat = [NSString stringWithFormat:@"%@", alcoholResult.location_lat];
    NSString *locationLong = [NSString stringWithFormat:@"%@", alcoholResult.location_long];
    NSString *alcoholValue = [NSString stringWithFormat:@"%@", alcoholResult.alcohol_value];
    NSString *bactrackId = [NSString stringWithFormat:@"%@", alcoholResult.backtrack_id];
    NSString *useCount = [NSString stringWithFormat:@"%@", alcoholResult.use_Number];
    NSString *drivingDiv = [NSString stringWithFormat:@"%@", alcoholResult.driving_div];
    NSData *photoData = alcoholResult.photo_file;
    
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
        if ([task.accessibilityLabel isEqual:@"getApplicationApiUrl"])
        {
            [self successGetApplicationApiUrl];
        }
        else if ([task.accessibilityLabel isEqual:@"getAlcoholValueDiv"])
        {
            [self successGetAlcoholValueDiv];
        }
        else if ([task.accessibilityLabel isEqual:@"checkDriver"])
        {
            [self successDriver];
        }
        else if ([task.accessibilityLabel isEqual:@"checkCarNo"])
        {
            [self successCarNo];
        }
        else
        {
            [self successHttpRequest];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // エラー情報を表示する。
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) failureHttpRequest:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendError
{
    buttonSend.enabled = true;
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
//        [self getAlcoholValueDiv];
        [self checkDriver];
        
        
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
           self->buttonSend.enabled = false;
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
        [self checkDriver];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"会社情報の取得が出来ませんでした"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
           self->buttonSend.enabled = false;
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
 }

// データ受信が終わったら呼び出されるメソッド。
- (void) successDriver {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    // 受信したデータをUITextViewに表示する。
    if ([html hasPrefix:@"OK"])
    {
        [self checkCarNo];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"運転車が登録されていません"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
           self->buttonSend.enabled = true;
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

// データ受信が終わったら呼び出されるメソッド。
- (void) successCarNo {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    // 受信したデータをUITextViewに表示する。
    if ([html hasPrefix:@"OK"])
    {
        [self sendData];
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
           self->buttonSend.enabled = false;
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"送信しました。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        }]];
        [self presentViewController:alert animated:YES completion:nil];

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"2" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self changeSendFlg];
        buttonSend.enabled = false;
    }
    else if ([trim isEqualToString:@"KEY_NG"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登録チェックエラー" message:@"送信済みです。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"2" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self changeSendFlg];
        buttonSend.enabled = false;
    }
    else if ([trim isEqualToString:@"DRIVER_NG"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登録チェックエラー" message:@"運転者が登録されていません。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"1" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self changeSendFlgToNG];
        buttonSend.enabled = false;
    }
    else if ([trim isEqualToString:@"CAR_NUMBER_NG"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登録チェックエラー" message:@"車番が登録されていません。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"1" forKey:KEY_SEND_FLG];
        [ud synchronize];
        [self changeSendFlgToNG];
        buttonSend.enabled = false;
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"送信時エラー" message:@"送信できませんでした。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)changeSendFlg
{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    NSPredicate *preparedSendList = [NSPredicate predicateWithFormat:@"_id=%d", self._id];
    RLMResults *result = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedSendList];
    
    if (result.count != 0)
    {
        alcoholResult.send_flg = @"2";

        [realm addOrUpdateObject:alcoholResult];
        [realm commitWriteTransaction];
    }

}

- (void)changeSendFlgToNG
{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    NSPredicate *preparedSendList = [NSPredicate predicateWithFormat:@"_id=%d", self._id];
    RLMResults *result = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedSendList];
    
    if (result.count != 0)
    {
        alcoholResult.send_flg = @"1";

        [realm addOrUpdateObject:alcoholResult];
        [realm commitWriteTransaction];
    }

}

@end
