//
//  DrivingReportEditViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/27.
//

#import "DrivingReportEditViewController.h"
#import "AppConsts.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReport.h"
#import "RealmLocalDataDrivingReportDetail.h"

@interface DrivingReportEditViewController () <NSURLSessionDataDelegate>
{
    UIDatePicker* datePickerDrivingStartYmd;
    UIDatePicker* datePickerDrivingEndYmd;
    UIDatePicker* datePickerDrivingStartHm;
    UIDatePicker* datePickerDrivingEndHm;
    
    RealmLocalDataDrivingReport *drivingReport;
    
    NSMutableData *receivedData;
    int retryCount;
}
@end

@implementation DrivingReportEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"日報入力"];
    
    buttonSave.exclusiveTouch = true;
    buttonDetail.exclusiveTouch = true;
    buttonSend.exclusiveTouch = true;
    buttonDelete.exclusiveTouch = true;
    
    textDriverCode.delegate = self;
    textCarNumber.delegate = self;
    textDrivingStartKm.delegate = self;
    textDrivingEndKm.delegate = self;
    textResuelingStatus.delegate = self;
    textAbnormalReport.delegate = self;
    textInstruction.delegate = self;
//20231211
    textFreeFld1.delegate = self;
    textFreeFld2.delegate = self;
    textFreeFld3.delegate = self;
//20231211
    [self createDrivingStartYmdPicker];
    [self createDrivingStartHmPicker];
    [self createDrivingEndYmdPicker];
    [self createDrivingEndHmPicker];
    [self createDrivingStartKmNumberPad];
    [self createDrivingEndKmNumberPad];
    
    [scrollView addSubview:contentsView];
    
    // データ取得
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *preparedDrivingReport = [NSPredicate predicateWithFormat:@"_id=%d", self._id];
    RLMResults *drivingReportList = [RealmLocalDataDrivingReport objectsInRealm:realm withPredicate:preparedDrivingReport];
    
    if (drivingReportList.count != 0)
    {
        drivingReport = drivingReportList[0];
        
        // データセット
        textDriverCode.text = drivingReport.driver_code;
        textCarNumber.text = drivingReport.car_number;
        textDrivingStartYmd.text = [self formatDateString:drivingReport.driving_start_ymd];
        [datePickerDrivingStartYmd setDate:[self formatDate:drivingReport.driving_start_ymd]];
        textDrivingStartHm.text = [self formatTimeString:drivingReport.driving_start_hm];
        [datePickerDrivingStartHm setDate:[self formatTime:drivingReport.driving_start_hm]];
        textDrivingEndYmd.text = [self formatDateString:drivingReport.driving_end_ymd];
        [datePickerDrivingEndYmd setDate:[self formatDate:drivingReport.driving_end_ymd]];
        textDrivingEndHm.text = [self formatTimeString:drivingReport.driving_end_hm];
        [datePickerDrivingEndHm setDate:[self formatTime:drivingReport.driving_end_hm]];
        textDrivingStartKm.text = [NSString stringWithFormat:@"%.0f", drivingReport.driving_start_km];
        textDrivingEndKm.text = [NSString stringWithFormat:@"%.0f", drivingReport.driving_end_km];
        textResuelingStatus.text = drivingReport.refueling_status;
        textAbnormalReport.text = drivingReport.abnormal_report;
        textInstruction.text = drivingReport.instruction;
//20231211
        textFreeTitle1.text = drivingReport.free_title1;
        textFreeTitle2.text = drivingReport.free_title2;
        textFreeTitle3.text = drivingReport.free_title3;
        textFreeFld1.text = drivingReport.free_fld1;
        textFreeFld2.text = drivingReport.free_fld2;
        textFreeFld3.text = drivingReport.free_fld3;
//20231211
    } else {
//20231211
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        textDriverCode.text=[ud stringForKey:KEY_DRIVER];
        textCarNumber.text=[ud stringForKey:KEY_CAR_NO];
        textFreeTitle1.text=[ud stringForKey:KEY_FREE_TITLE1];
        textFreeTitle2.text=[ud stringForKey:KEY_FREE_TITLE2];
        textFreeTitle3.text=[ud stringForKey:KEY_FREE_TITLE3];
//20231211
    }
 
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self setControlEnable];

}

- (void)setControlEnable
{
    buttonSave.enabled = true;
    buttonDetail.enabled = true;
    buttonDelete.enabled = true;
    buttonSend.enabled = true;
    
    if (drivingReport == nil)
    {
        buttonDelete.enabled = false;
    }
    else
    {
        if ([drivingReport.send_flg isEqualToString:@"1"])
        {
            textDriverCode.enabled = false;
            textCarNumber.enabled = false;
            textDrivingStartYmd.enabled = false;
            textDrivingStartHm.enabled = false;
            textDrivingEndYmd.enabled = false;
            textDrivingEndHm.enabled = false;
            textDrivingStartKm.enabled = false;
            textDrivingEndKm.enabled = false;
            textResuelingStatus.enabled = false;
            textAbnormalReport.enabled = false;
            textInstruction.enabled = false;
//20231211
            textFreeFld1.enabled = false;
            textFreeFld2.enabled = false;
            textFreeFld3.enabled = false;
//20231211
            buttonDeleteDrivingStartYmd.enabled = false;
            buttonDeleteDrivingStartHm.enabled = false;
            buttonDeleteDrivingEndYmd.enabled = false;
            buttonDeleteDrivingEndHm.enabled = false;
            
            buttonSave.enabled = false;
            buttonSend.enabled = false;
//20231211
            buttonDelete.enabled = false;
//20231211

        }
    }
//20231211
    if([textFreeTitle1.text isEqualToString:@""])
    {
        textFreeTitle1.hidden=YES;
        textFreeFld1.hidden=YES;
    } else {
        textFreeTitle1.hidden=NO;
        textFreeFld1.hidden=NO;
    }
    if([textFreeTitle2.text isEqualToString:@""])
    {
        textFreeTitle2.hidden=YES;
        textFreeFld2.hidden=YES;
    } else {
        textFreeTitle2.hidden=NO;
        textFreeFld2.hidden=NO;
    }
    if([textFreeTitle3.text isEqualToString:@""])
    {
        textFreeTitle3.hidden=YES;
        textFreeFld3.hidden=YES;
    } else {
        textFreeTitle3.hidden=NO;
        textFreeFld3.hidden=NO;
    }
//20231211

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

- (void)createDrivingStartYmdPicker
{
    // DatePickerの設定
    datePickerDrivingStartYmd = [[UIDatePicker alloc]init];
    
    [datePickerDrivingStartYmd setDatePickerMode:UIDatePickerModeDate];
    if (@available(iOS 13.4, *)) {
        [datePickerDrivingStartYmd setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerDrivingStartYmd addTarget:self action:@selector(updateDrivingStartYmd:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textDrivingStartYmd.inputView = datePickerDrivingStartYmd;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingStartYmd)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textDrivingStartYmd.inputAccessoryView = keyboardDoneButtonView;
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

- (void)createDrivingEndYmdPicker
{
    // DatePickerの設定
    datePickerDrivingEndYmd = [[UIDatePicker alloc]init];
    
    [datePickerDrivingEndYmd setDatePickerMode:UIDatePickerModeDate];
    if (@available(iOS 13.4, *)) {
        [datePickerDrivingEndYmd setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerDrivingEndYmd addTarget:self action:@selector(updateDrivingEndYmd:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textDrivingEndYmd.inputView = datePickerDrivingEndYmd;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingEndYmd)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textDrivingEndYmd.inputAccessoryView = keyboardDoneButtonView;
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

- (IBAction)buttonDeleteStartYmdTouchUpInside:(id)sender {
    textDrivingStartYmd.text = @"";
}

- (IBAction)buttonDeleteStartHmTouchUpInside:(id)sender {
    textDrivingStartHm.text = @"";
}

- (IBAction)buttonDeleteEndYmdTouchUpInside:(id)sender {
    textDrivingEndYmd.text = @"";
}

- (IBAction)buttonDeleteEndHmTouchUpInside:(id)sender {
    textDrivingEndHm.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

-(void)updateDatePicker:(UIDatePicker *)picker :(UITextField *)textField
{
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [df stringFromDate:picker.date];
    textField.text = strDate;
}

-(void)updateTimePicker:(UIDatePicker *)picker :(UITextField *)textField
{
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"HH:mm"];
    NSString *strDate = [df stringFromDate:picker.date];
    textField.text = strDate;
}

-(void)updateDrivingStartYmd:(id)sender
{
    [self updateDatePicker:sender :textDrivingStartYmd];
}

-(void)updateDrivingStartHm:(id)sender
{
    [self updateTimePicker:sender :textDrivingStartHm];
}

-(void)updateDrivingEndYmd:(id)sender
{
    [self updateDatePicker:sender :textDrivingEndYmd];
}

-(void)updateDrivingEndHm:(id)sender
{
    [self updateTimePicker:sender :textDrivingEndHm];
}

-(void)pickerDoneDrivingStartYmd
{
    [self updateDatePicker:datePickerDrivingStartYmd :textDrivingStartYmd];
    [self.view endEditing:YES];
}

-(void)pickerDoneDrivingStartHm
{
    [self updateTimePicker:datePickerDrivingStartHm :textDrivingStartHm];
    [self.view endEditing:YES];
}

-(void)pickerDoneDrivingEndYmd
{
    [self updateDatePicker:datePickerDrivingEndYmd :textDrivingEndYmd];
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
    
    if ([textDriverCode.text isEqualToString:@""])
    {
        errorMessage = @"運転者を入力してください";
    }
    else if ([textCarNumber.text isEqualToString:@""])
    {
        errorMessage = @"車番を入力してください";
    }
    else if ([textDrivingStartYmd.text isEqualToString:@""])
    {
        errorMessage = @"運転開始日付を入力してください";
    }
    else if ([textDrivingStartYmd.text isEqualToString:@""])
    {
        errorMessage = @"運転開始時刻を入力してください";
    }
    else if ([textDriverCode.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 50)
    {
        errorMessage = @"運転者が最大桁数を超えています";
    }
    else if ([textCarNumber.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 50)
    {
        errorMessage = @"車番が最大桁数を超えています";
    }
    else if ([textResuelingStatus.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 100)
    {
        errorMessage = @"給油状況が最大桁数を超えています";
    }
    else if ([textAbnormalReport.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        errorMessage = @"異常報告が最大桁数を超えています";
    }
    else if ([textInstruction.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        errorMessage = @"連絡事項が最大桁数を超えています";
    }
//20231211
    else if ([textFreeFld1.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        errorMessage = @"設定入力項目１が最大桁数を超えています";
    }
    else if ([textFreeFld2.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        errorMessage = @"設定入力項目２が最大桁数を超えています";
    }
    else if ([textFreeFld3.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        errorMessage = @"設定入力項目３が最大桁数を超えています";
    }
    else if ([textDrivingStartKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"乗務開始メータが最大桁数を超えています";
    }
    else if ([textDrivingEndKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"乗務終了メータが最大桁数を超えています";
    }
//20231211

    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingStartYmd.text isEqualToString:@""] && ![self isValidDate:textDrivingStartYmd.text])
        {
            errorMessage = @"運転開始日付が正しくありません";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingStartHm.text isEqualToString:@""] && ![self isValidTime:textDrivingStartHm.text])
        {
            errorMessage = @"運転開始時刻が正しくありません";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingEndYmd.text isEqualToString:@""] && ![self isValidDate:textDrivingEndYmd.text])
        {
            errorMessage = @"運転終了日付が正しくありません";
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
            errorMessage = @"乗務開始メーターは数値入力してください";
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![textDrivingEndKm.text isEqualToString:@""] && ![self isNumeric:textDrivingEndKm.text])
        {
            errorMessage = @"乗務終了メーターは数値入力してください";
        }
    }
    
//20231211
    NSString *st=[textDrivingStartYmd.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *ed=[textDrivingEndYmd.text stringByReplacingOccurrencesOfString:@"/" withString:@""];

    if ([errorMessage isEqualToString:@""])
    {
        if (![st isEqualToString:@""] && ![ed isEqualToString:@""]) {
            if ([ed intValue]<[st intValue])
            {
                errorMessage = @"運転終了日付が運転開始日付より前です";
            }
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        if (![st isEqualToString:@""] && ![ed isEqualToString:@""])
        {
            if ([ed intValue] == [st intValue])
            {
                NSString *st=[textDrivingStartHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
                NSString *ed=[textDrivingEndHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
                if (![st isEqualToString:@""] && ![ed isEqualToString:@""])
                {
                    if ([ed intValue]<[st intValue])
                    {
                        errorMessage = @"乗務終了時刻が乗務開始時刻より前です";
                        
                    }
                }
            }
        }
    }
    
    if ([errorMessage isEqualToString:@""])
    {
        NSString *st=textDrivingStartKm.text;
        NSString *ed=textDrivingEndKm.text;
        if (![st isEqualToString:@""] && ![ed isEqualToString:@""])
        {
            if ([ed doubleValue]<[st doubleValue])
            {
                errorMessage = @"乗務開始メーターが乗務終了メーターより大きいです";
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

- (BOOL)SaveData
{
    if ([self CheckData] == false)
    {
        return NO;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    if (drivingReport == nil)
    {
        drivingReport = [[RealmLocalDataDrivingReport alloc] init];
        
        int nextId = 1;
        
        NSNumber *maxId = [[RealmLocalDataDrivingReport allObjectsInRealm:realm] maxOfProperty:@"_id"];
        if (maxId != nil)
        {
            nextId = [maxId intValue] + 1;
        }
        
        drivingReport._id = nextId;
    }
    
    // 値セット
//20231211
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *company = [ud stringForKey:KEY_COMPANY];
    drivingReport.company_code = company;
//20231211
    
    drivingReport.driver_code = textDriverCode.text;
    drivingReport.car_number = textCarNumber.text;
    drivingReport.driving_start_ymd = [textDrivingStartYmd.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    drivingReport.driving_start_hm = [textDrivingStartHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    drivingReport.driving_end_ymd = [textDrivingEndYmd.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    drivingReport.driving_end_hm = [textDrivingEndHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    if ([textDrivingStartKm.text isEqualToString:@""])
    {
        drivingReport.driving_start_km = 0;
    }
    else
    {
        drivingReport.driving_start_km = [[textDrivingStartKm.text stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    }
    if ([textDrivingEndKm.text isEqualToString:@""])
    {
        drivingReport.driving_end_km = 0;
    }
    else
    {
        drivingReport.driving_end_km = [[textDrivingEndKm.text stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    }
    drivingReport.refueling_status = textResuelingStatus.text;
    drivingReport.abnormal_report = textAbnormalReport.text;
    drivingReport.instruction = textInstruction.text;
    drivingReport.send_flg = @"0";
    
//20231211
    drivingReport.free_title1 = textFreeTitle1.text;
    drivingReport.free_title2 = textFreeTitle2.text;
    drivingReport.free_title3 = textFreeTitle3.text;
    drivingReport.free_fld1 = textFreeFld1.text;
    drivingReport.free_fld2 = textFreeFld2.text;
    drivingReport.free_fld3 = textFreeFld3.text;
//20231211
    
    [realm addObject:drivingReport];
    
    [realm commitWriteTransaction];
 
    return YES;
}

- (IBAction)buttonDetailTouchUpInside:(id)sender {
    buttonDetail.enabled = false;
    
    if (![drivingReport.send_flg isEqualToString:@"1"])
    {
        if ([self SaveData] == false)
        {
            buttonDetail.enabled = true;
            return;
        }
    }
    
//20231211 値保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:textDriverCode.text forKey:KEY_DRIVER];
    [ud setObject:textCarNumber.text forKey:KEY_CAR_NO];
    [ud synchronize];

    // 移動
    drivingReportDetailViewController = [[DrivingReportDetailViewController alloc] initWithNibName:@"DrivingReportDetailViewController" bundle:nil];
    drivingReportDetailViewController.driving_report_id = drivingReport._id;
    [self.navigationController pushViewController:drivingReportDetailViewController animated:YES];
}

 - (IBAction)buttonSendTouchUpInside:(id)sender {
    buttonSend.enabled = false;
     
     if ([self SaveData] == false)
     {
         buttonSend.enabled = true;
         return;
     }
     
     retryCount = 0;
     
     [self sendData];
}


- (void)sendData {
    
    // 送信内容を stringsBody に入れる
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // 明細取得
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"driving_report_id=%d", drivingReport._id];
    RLMResults *drivingReportDetailList = [RealmLocalDataDrivingReportDetail objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    
    RLMSortDescriptor *sort1 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_start_hm" ascending:YES];
    RLMSortDescriptor *sort2 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_end_hm" ascending:YES];
    NSArray *sortDescriptor = [NSArray arrayWithObjects:sort1, sort2, nil];
    
    drivingReportDetailList = [drivingReportDetailList sortedResultsUsingDescriptors:sortDescriptor];
    
    // JSONデータ作成
    NSMutableArray *jsonArray = [NSMutableArray array];
    
    NSMutableDictionary *headerJson = [NSMutableDictionary dictionary];
    [headerJson setObject:[NSString stringWithFormat:@"%d", drivingReport._id] forKey:@"id"];
    [headerJson setObject:drivingReport.driver_code forKey:@"driver_code"];
    [headerJson setObject:drivingReport.car_number forKey:@"car_number"];
    [headerJson setObject:drivingReport.driving_start_ymd forKey:@"driving_start_ymd"];
    [headerJson setObject:drivingReport.driving_start_hm forKey:@"driving_start_hm"];
    [headerJson setObject:drivingReport.driving_end_ymd forKey:@"driving_end_ymd"];
    [headerJson setObject:drivingReport.driving_end_hm forKey:@"driving_end_hm"];
    [headerJson setObject:[NSString stringWithFormat:@"%.0f", drivingReport.driving_start_km] forKey:@"driving_start_km"];
    [headerJson setObject:[NSString stringWithFormat:@"%.0f", drivingReport.driving_end_km] forKey:@"driving_end_km"];
    [headerJson setObject:drivingReport.refueling_status forKey:@"refueling_status"];
    [headerJson setObject:drivingReport.abnormal_report forKey:@"abnormal_report"];
    [headerJson setObject:drivingReport.instruction forKey:@"instruction"];
    [headerJson setObject:drivingReport.send_flg forKey:@"send_flg"];
//20231211
    [headerJson setObject:drivingReport.free_title1 forKey:@"free_title1"];
    [headerJson setObject:drivingReport.free_title2 forKey:@"free_title2"];
    [headerJson setObject:drivingReport.free_title3 forKey:@"free_title3"];
    [headerJson setObject:drivingReport.free_fld1 forKey:@"free_fld1"];
    [headerJson setObject:drivingReport.free_fld2 forKey:@"free_fld2"];
    [headerJson setObject:drivingReport.free_fld3 forKey:@"free_fld3"];
//20231211
    NSMutableArray *detailJsonArray = [NSMutableArray array];
    for (RealmLocalDataDrivingReportDetail *detail in drivingReportDetailList)
    {
        NSMutableDictionary *detailJson = [NSMutableDictionary dictionary];
        [detailJson setObject:[NSString stringWithFormat:@"%d", detail._id] forKey:@"id"];
        [detailJson setObject:[NSString stringWithFormat:@"%d", detail.driving_report_id] forKey:@"driving_report_id"];
        [detailJson setObject:detail.destination forKey:@"destination"];
        [detailJson setObject:detail.driving_start_hm forKey:@"driving_start_hm"];
//20231211
        [detailJson setObject:[NSString stringWithFormat:@"%.0f", detail.driving_start_km] forKey:@"driving_start_km"];
//20231211
        [detailJson setObject:detail.driving_end_hm forKey:@"driving_end_hm"];
//20231211
        [detailJson setObject:[NSString stringWithFormat:@"%.0f", detail.driving_end_km] forKey:@"driving_end_km"];
//20231211
        [detailJson setObject:detail.cargo_weight forKey:@"cargo_weight"];
        [detailJson setObject:detail.cargo_status forKey:@"cargo_status"];
        [detailJson setObject:detail.note forKey:@"note"];
        
        [detailJsonArray addObject:detailJson];
    }
    
    [headerJson setObject:detailJsonArray forKey:@"detail"];
    
    [jsonArray addObject:headerJson];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", jsonString);
    
    // 接続先
    NSString *http_url = [ud stringForKey:KEY_HTTP_URL];
    // URL を設定し、NSMutableURLRequest を作成
    NSString *urlString = [NSString stringWithFormat:@"%@%@", http_url, HTTP_WRITE_DRIVING_REPORT];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:5];
    
    // body を初期化し、boundary を指定
    NSMutableData *body = [[NSMutableData alloc] init];
    NSString *boundary = [NSString stringWithFormat:@"---------------------------%d", arc4random() %
                          10000000];
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    // jsonData
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"jsonData\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
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
    NSString *jsonString
    = [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
 
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    BOOL status = [[json objectForKey:@"status"] boolValue];
    
    // 受信したデータをUITextViewに表示する。
    if (status)
    {
        // 送信成功
        NSDictionary *dicData = [json objectForKey:@"data"];
        NSMutableArray *arrIds = [dicData objectForKey:@"driving_report_id"];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        for (NSString *driving_report_id in arrIds)
        {
            NSPredicate *preparedDrivingReport = [NSPredicate predicateWithFormat:@"_id=%d", [driving_report_id intValue]];
            RLMResults *drivingReportList = [RealmLocalDataDrivingReport objectsInRealm:realm withPredicate:preparedDrivingReport];
            
            if (drivingReportList.count != 0)
            {
                drivingReport = drivingReportList[0];
                drivingReport.send_flg = @"1";
                [realm addObject:drivingReport];
            }
        }
        [realm commitWriteTransaction];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        buttonSend.enabled = true;
        
        // 送信失敗
        NSDictionary *dicError = [json objectForKey:@"error"];
        NSString *errorMessage = [dicError objectForKey:@"message"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"送信失敗" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            // OKボタン
            [self sendError];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        //[self performSelector:@selector(sendData) withObject:nil afterDelay:60.0];
        [self sendData];
    }
}

- (void)sendError
{
    buttonSend.enabled = true;
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
    
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"driving_report_id=%d", drivingReport._id];
    RLMResults *drivingReportDetailList = [RealmLocalDataDrivingReportDetail objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    [realm deleteObjects:drivingReportDetailList];
    
    [realm deleteObject:drivingReport];
    [realm commitWriteTransaction];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelDelete
{
    buttonDelete.enabled = true;
}

@end
