//
//  DrivingReportDetailEditViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/06.
//

#import "DrivingReportDetailEditViewController.h"
#import "AppConsts.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReport.h"
#import "RealmLocalDataDrivingReportDetail.h"
#import "RealmLocalDataDrivingReportDestination.h"

@interface DrivingReportDetailEditViewController ()
{
    UIDatePicker* datePickerDrivingStartHm;
    UIDatePicker* datePickerDrivingEndHm;
    
    RealmLocalDataDrivingReport *drivingReport;
    RealmLocalDataDrivingReportDetail *drivingReportDetail;
}
@end

@implementation DrivingReportDetailEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"明細入力"];
    
    buttonSave.exclusiveTouch = true;
    buttonDelete.exclusiveTouch = true;
    
    textDestination.delegate = self;
    textDrivingStartKm.delegate = self;
    textDrivingEndKm.delegate = self;
    textCargoWeight.delegate = self;
    textCargoStatus.delegate = self;
    textNote.delegate = self;
    
    [self createDrivingStartHmPicker];
    [self createDrivingEndHmPicker];
    [self createDrivingStartKmNumberPad];
    [self createDrivingEndKmNumberPad];
    
    [scrollView addSubview:contentsView];
    
    // データ取得
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *preparedDrivingReport = [NSPredicate predicateWithFormat:@"_id=%d", self.driving_report_id];
    drivingReport = [[RealmLocalDataDrivingReport objectsInRealm:realm withPredicate:preparedDrivingReport] firstObject];
    
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"_id=%d", self.driving_report_detail_id];
    RLMResults *drivingReportDetailList = [RealmLocalDataDrivingReportDetail objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    
    if (drivingReportDetailList.count != 0)
    {
        drivingReportDetail = drivingReportDetailList[0];
        
        // データセット
        textDestination.text = drivingReportDetail.destination;
        textDrivingStartHm.text = [self formatTimeString:drivingReportDetail.driving_start_hm];
        [datePickerDrivingStartHm setDate:[self formatTime:drivingReportDetail.driving_start_hm]];
        textDrivingStartKm.text = [NSString stringWithFormat:@"%.0f", drivingReportDetail.driving_start_km];
        textDrivingEndHm.text = [self formatTimeString:drivingReportDetail.driving_end_hm];
        [datePickerDrivingEndHm setDate:[self formatTime:drivingReportDetail.driving_end_hm]];
        textDrivingEndKm.text = [NSString stringWithFormat:@"%.0f", drivingReportDetail.driving_end_km];
        textCargoWeight.text = drivingReportDetail.cargo_weight;
        textCargoStatus.text = drivingReportDetail.cargo_status;
        textNote.text = drivingReportDetail.note;
    }
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setControlEnable];
}

- (void)setControlEnable
{
    buttonSave.enabled = true;
    buttonDelete.enabled = true;
    
    if (drivingReportDetail == nil)
    {
        buttonDelete.enabled = false;
    }
    else
    {
        if ([drivingReport.send_flg isEqualToString:@"1"])
        {
            textDestination.enabled = false;
            textDrivingStartHm.enabled = false;
            textDrivingStartKm.enabled = false;
            textDrivingEndHm.enabled = false;
            textDrivingEndKm.enabled = false;
            textCargoWeight.enabled = false;
            textCargoStatus.enabled = false;
            textNote.enabled = false;
            
            buttonDestinationSelect.enabled = false;
            buttonDeleteDrivingStartHm.enabled = false;
            buttonDeleteDrivingEndHm.enabled = false;
            
            buttonSave.enabled = false;
            buttonDelete.enabled = false;
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

- (void)createDrivingStartHmPicker
{
    // DatePickerの設定
    datePickerDrivingStartHm = [[UIDatePicker alloc]init];
    
    [datePickerDrivingStartHm setDatePickerMode:UIDatePickerModeTime];
    if (@available(iOS 13.4, *)) {
        [datePickerDrivingStartHm setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerDrivingStartHm addTarget:self action:@selector(updateDrivingStartHm:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textDrivingStartHm.inputView = datePickerDrivingStartHm;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingStartHm)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textDrivingStartHm.inputAccessoryView = keyboardDoneButtonView;
}

- (void)createDrivingEndHmPicker
{
    // DatePickerの設定
    datePickerDrivingEndHm = [[UIDatePicker alloc]init];
    
    [datePickerDrivingEndHm setDatePickerMode:UIDatePickerModeTime];
    if (@available(iOS 13.4, *)) {
        [datePickerDrivingEndHm setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerDrivingEndHm addTarget:self action:@selector(updateDrivingEndHm:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textDrivingEndHm.inputView = datePickerDrivingEndHm;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingEndHm)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textDrivingEndHm.inputAccessoryView = keyboardDoneButtonView;
}

- (void)createDrivingStartKmNumberPad
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"クリア" style:UIBarButtonItemStylePlain target:self action:@selector(cancelDrivingStartKmNumberPad)],
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"閉じる" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithDrivingStartKmNumberPad)]];
    [numberToolbar sizeToFit];
    textDrivingStartKm.inputAccessoryView = numberToolbar;
}

-(void)cancelDrivingStartKmNumberPad{
    textDrivingStartKm.text = @"";
}

-(void)doneWithDrivingStartKmNumberPad{
    [textDrivingStartKm resignFirstResponder];
}

- (void)createDrivingEndKmNumberPad
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"クリア" style:UIBarButtonItemStylePlain target:self action:@selector(cancelDrivingEndKmNumberPad)],
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"閉じる" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithDrivingEndKmNumberPad)]];
    [numberToolbar sizeToFit];
    textDrivingEndKm.inputAccessoryView = numberToolbar;
}

-(void)cancelDrivingEndKmNumberPad{
    textDrivingEndKm.text = @"";
}

-(void)doneWithDrivingEndKmNumberPad{
    [textDrivingEndKm resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [contentsView setFrame:CGRectMake(0, 0, scrollView.frame.size.width, contentsView.frame.size.height)];
    CGSize contentsSize = CGSizeMake(scrollView.frame.size.width, contentsView.frame.size.height);
    [scrollView setContentSize:contentsSize];
    [scrollView flashScrollIndicators];
}

- (IBAction)buttonDestinationSelectTouchUpInside:(id)sender {
    // 移動
    drivingReportDestinationViewController = [[DrivingReportDestinationViewController alloc] initWithNibName:@"DrivingReportDestinationViewController" bundle:nil];
    [self.navigationController pushViewController:drivingReportDestinationViewController animated:YES];
}

- (IBAction)buttonDeleteStartHmTouchUpInside:(id)sender {
    textDrivingStartHm.text = @"";
}

- (IBAction)buttonDeleteEndHmTouchUpInside:(id)sender {
    textDrivingEndHm.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

-(void)updateTimePicker:(UIDatePicker *)picker :(UITextField *)textField
{
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"HH:mm"];
    NSString *strDate = [df stringFromDate:picker.date];
    textField.text = strDate;
}

-(void)updateDrivingStartHm:(id)sender
{
    [self updateTimePicker:sender :textDrivingStartHm];
}

-(void)updateDrivingEndHm:(id)sender
{
    [self updateTimePicker:sender :textDrivingEndHm];
}

-(void)pickerDoneDrivingStartHm
{
    [self updateTimePicker:datePickerDrivingStartHm :textDrivingStartHm];
    [self.view endEditing:YES];
}

-(void)pickerDoneDrivingEndHm
{
    [self updateTimePicker:datePickerDrivingEndHm :textDrivingEndHm];
    [self.view endEditing:YES];
}

- (IBAction)buttonSaveTouchUpInside:(id)sender {
    buttonSave.enabled = false;
    
    if([self SaveData] == false)
    {
        buttonSave.enabled = true;
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)CheckData
{
    NSString *errorMessage = @"";
    
    if ([textDestination.text isEqualToString:@""])
    {
        errorMessage = @"行先を入力してください";
    }
    else if ([textDestination.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 100)
    {
        errorMessage = @"行先が最大桁数を超えています";
    }
    else if ([textCargoWeight.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 100)
    {
        errorMessage = @"重量/個数が最大桁数を超えています";
    }
    else if ([textCargoStatus.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 100)
    {
        errorMessage = @"積載状況が最大桁数を超えています";
    }
    else if ([textNote.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 100)
    {
        errorMessage = @"備考が最大桁数を超えています";
    }
//20231211
    else if ([textDrivingStartKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"発メータが最大桁数を超えています";
    }
    else if ([textDrivingEndKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"着メータが最大桁数を超えています";
    }
//20231211

    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingStartHm.text isEqualToString:@""] && ![self isValidTime:textDrivingStartHm.text])
        {
            errorMessage = @"運転開始時刻が正しくありません";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingEndHm.text isEqualToString:@""] && ![self isValidTime:textDrivingEndHm.text])
        {
            errorMessage = @"運転終了時刻が正しくありません";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingStartKm.text isEqualToString:@""] && ![self isNumeric:textDrivingStartKm.text])
        {
            errorMessage = @"発メーターは数値入力してください";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingEndKm.text isEqualToString:@""] && ![self isNumeric:textDrivingEndKm.text])
        {
            errorMessage = @"着メーターは数値入力してください";
        }
    }
    
//20231211
/*
    if ([errorMessage isEqualToString:@""])
    {
        NSString *st=[textDrivingStartHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *ed=[textDrivingEndHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
        if (![st isEqualToString:@""] && ![ed isEqualToString:@""])
        {
            if ([ed intValue]<[st intValue])
            {
                errorMessage = @"着時刻が発時刻より前です";
            }
        }
    }
*/
    if ([errorMessage isEqualToString:@""])
    {
        NSString *st=textDrivingStartKm.text;
        NSString *ed=textDrivingEndKm.text;
        if (![st isEqualToString:@""] && ![ed isEqualToString:@""])
        {
            if ([ed doubleValue]<[st doubleValue])
            {
                errorMessage = @"発メーターが着メーターより大きいです";
            }
        }
    }
//20231211

    if (![errorMessage isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:errorMessage
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
           //ボタンがタップされた際の処理
       }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    
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

- (BOOL)SaveData
{
    if ([self CheckData] == false)
    {
        return NO;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    if (drivingReportDetail == nil)
    {
        drivingReportDetail = [[RealmLocalDataDrivingReportDetail alloc] init];
        
        int nextId = 1;
        
        NSNumber *maxId = [[RealmLocalDataDrivingReportDetail allObjectsInRealm:realm] maxOfProperty:@"_id"];
        if (maxId != nil)
        {
            nextId = [maxId intValue] + 1;
        }
        
        drivingReportDetail._id = nextId;
    }
    
    // 値セット
    drivingReportDetail.driving_report_id = self.driving_report_id;
    drivingReportDetail.destination= textDestination.text;
    drivingReportDetail.driving_start_hm = [textDrivingStartHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    if ([textDrivingStartKm.text isEqualToString:@""])
    {
        drivingReportDetail.driving_start_km = 0;
    }
    else
    {
        drivingReportDetail.driving_start_km = [[textDrivingStartKm.text stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    }
    drivingReportDetail.driving_end_hm = [textDrivingEndHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    if ([textDrivingEndKm.text isEqualToString:@""])
    {
        drivingReportDetail.driving_end_km = 0;
    }
    else
    {
        drivingReportDetail.driving_end_km = [[textDrivingEndKm.text stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    }
    drivingReportDetail.cargo_weight = textCargoWeight.text;
    drivingReportDetail.cargo_status = textCargoStatus.text;
    drivingReportDetail.note = textNote.text;
    
    [realm addObject:drivingReportDetail];
    
    // 行先
    NSPredicate *preparedDrivingReportDestination = [NSPredicate predicateWithFormat:@"destination=%@", textDestination.text];
    RLMResults *drivingReportDestinationList = [RealmLocalDataDrivingReportDestination objectsInRealm:realm withPredicate:preparedDrivingReportDestination];
    
    if (drivingReportDestinationList.count == 0)
    {
        RealmLocalDataDrivingReportDestination *drivingReportDestination = [[RealmLocalDataDrivingReportDestination alloc] init];
        
        int nextId = 1;
        
        NSNumber *maxId = [[RealmLocalDataDrivingReportDestination allObjectsInRealm:realm] maxOfProperty:@"_id"];
        if (maxId != nil)
        {
            nextId = [maxId intValue] + 1;
        }
        
        drivingReportDestination._id = nextId;
        drivingReportDestination.destination = textDestination.text;
//20231211
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *company = [ud stringForKey:KEY_COMPANY];
        drivingReportDestination.company_code = company;
//20231211

        [realm addObject:drivingReportDestination];
    }
    
    // 運転メーター更新
/*
20231211
    NSNumber *tempMinKm = [[RealmLocalDataDrivingReportDetail allObjectsInRealm:realm] minOfProperty:@"driving_start_km"];
    double minKm = [tempMinKm doubleValue];
    
    NSNumber *tempMaxKm = [[RealmLocalDataDrivingReportDetail allObjectsInRealm:realm] maxOfProperty:@"driving_end_km"];
    double maxKm = [tempMaxKm doubleValue];
    
    drivingReport.driving_start_km = minKm;
    drivingReport.driving_end_km = maxKm;
*/
    [realm addObject:drivingReport];
    
    [realm commitWriteTransaction];
 
    return YES;
}

- (IBAction)buttonDeleteTouchUpInside:(id)sender {
    buttonDelete.enabled = false;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認"
                                                                             message:@"削除しますか？"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
       //ボタンがタップされた際の処理
       [self deleteData];
   }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        //ボタンがタップされた際の処理
        [self cancelDelete];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteData
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:drivingReportDetail];
    [realm commitWriteTransaction];
 
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelDelete
{
    buttonDelete.enabled = true;
}

- (void)setDestination:(NSString *)destination
{
    textDestination.text = destination;
}

@end
