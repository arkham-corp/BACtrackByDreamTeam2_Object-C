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
#import <UIKit/UIKit.h>

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
    
    intTitleArray = [NSMutableArray array];

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
    textFreeFld1.delegate = self;
    textFreeFld2.delegate = self;
    textFreeFld3.delegate = self;
//202404 start
    textFreeFld4.delegate = self;
    textFreeFld5.delegate = self;
    textFreeFld6.delegate = self;
    textFreeFld7.delegate = self;
    textFreeFld8.delegate = self;
//202404 finish
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
//202404 start

        if(![drivingReport.free_title1 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title1 setfld:drivingReport.free_fld1 setdiv:drivingReport.free_div1 setreq:@"1"];
        }
        if(![drivingReport.free_title2 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title2 setfld:drivingReport.free_fld2 setdiv:drivingReport.free_div2 setreq:@"2"];
        }
        if(![drivingReport.free_title3 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title3 setfld:drivingReport.free_fld3 setdiv:drivingReport.free_div3 setreq:@"3"];
        }
        if(![drivingReport.free_title4 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title4 setfld:drivingReport.free_fld4 setdiv:drivingReport.free_div4 setreq:@"4"];
        }
        if(![drivingReport.free_title5 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title5 setfld:drivingReport.free_fld5 setdiv:drivingReport.free_div5 setreq:@"5"];
        }
        if(![drivingReport.free_title6 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title6 setfld:drivingReport.free_fld6 setdiv:drivingReport.free_div6 setreq:@"6"];
        }
        if(![drivingReport.free_title7 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title7 setfld:drivingReport.free_fld7 setdiv:drivingReport.free_div7 setreq:@"7"];
        }
        if(![drivingReport.free_title8 isEqualToString:@""]) {
            [self setTitle: drivingReport.free_title8 setfld:drivingReport.free_fld8 setdiv:drivingReport.free_div8 setreq:@"8"];
        }

//202404 finish
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        textDriverCode.text = [ud stringForKey:KEY_DRIVER];
        textCarNumber.text = [ud stringForKey:KEY_CAR_NO];
        
//202404 start
        NSString *div = [ud stringForKey:KEY_FREE_DIVISION1];
        NSString *title = [ud stringForKey:KEY_FREE_TITLE1];
        if(![title isEqualToString:@""]) {
            [self setTitle: title setfld:@"" setdiv:div setreq:@"1"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE2];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION2];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"2"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE3];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION3];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"3"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE4];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION4];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"4"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE5];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION5];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"5"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE6];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION6];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"6"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE7];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION7];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"7"];
        }
        title = [ud stringForKey:KEY_FREE_TITLE8];
        if(![title isEqualToString:@""]) {
            div = [ud stringForKey:KEY_FREE_DIVISION8];
            [self setTitle: title setfld:@"" setdiv:div setreq:@"8"];
        }
//202404 finish

        NSDate *now = [NSDate date];
        
        // 1. 各DatePickerの初期値を「現在日時」にする
        [datePickerDrivingStartYmd setDate:now animated:NO];
        [datePickerDrivingStartHm setDate:now animated:NO];
        
        // 2. 表示用のTextFieldにもフォーマットした文字列をセットする
        [self updateDatePicker:datePickerDrivingStartYmd :textDrivingStartYmd];
        [self updateTimePicker:datePickerDrivingStartHm :textDrivingStartHm];
        // ★★★ ここまで追加 ★★★
    }
 
}
- (void)setTitle:(NSString *)title setfld:(NSString *)fld setdiv:(NSString *)div setreq:(NSString *)req
{
    if([textFreeTitle1.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"1"];
        [intTitleArray addObject:str];
        textFreeTitle1.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld1.alpha = 1;
            swFreeFld1.alpha = 0;
            textFreeFld1.text = fld;
        } else {
            textFreeFld1.alpha = 0;
            swFreeFld1.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld1.on = YES;
            } else {
                swFreeFld1.on = NO;
            }
        }
    } else if([textFreeTitle2.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"2"];
        [intTitleArray addObject:str];
        textFreeTitle2.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld2.alpha = 1;
            swFreeFld2.alpha = 0;
            textFreeFld2.text = fld;
        } else {
            textFreeFld2.alpha = 0;
            swFreeFld2.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld2.on = YES;
            } else {
                swFreeFld2.on = NO;
            }
        }
    } else if([textFreeTitle3.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"3"];
        [intTitleArray addObject:str];
        textFreeTitle3.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld3.alpha = 1;
            swFreeFld3.alpha = 0;
            textFreeFld3.text = fld;
        } else {
            textFreeFld3.alpha = 0;
            swFreeFld3.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld3.on = YES;
            } else {
                swFreeFld3.on = NO;
            }
        }
    } else if([textFreeTitle4.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"4"];
        [intTitleArray addObject:str];
        textFreeTitle4.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld4.alpha = 1;
            swFreeFld4.alpha = 0;
            textFreeFld4.text = fld;
        } else {
            textFreeFld4.alpha = 0;
            swFreeFld4.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld4.on = YES;
            } else {
                swFreeFld4.on = NO;
            }
        }
    } else if([textFreeTitle5.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"5"];
        [intTitleArray addObject:str];
        textFreeTitle5.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld5.alpha = 1;
            swFreeFld5.alpha = 0;
            textFreeFld5.text = fld;
        } else {
            textFreeFld5.alpha = 0;
            swFreeFld5.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld5.on = YES;
            } else {
                swFreeFld5.on = NO;
            }
        }
    } else if([textFreeTitle6.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"6"];
        [intTitleArray addObject:str];
        textFreeTitle6.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld6.alpha = 1;
            swFreeFld6.alpha = 0;
            textFreeFld6.text = fld;
        } else {
            textFreeFld6.alpha = 0;
            swFreeFld6.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld6.on = YES;
            } else {
                swFreeFld6.on = NO;
            }
        }
    } else if([textFreeTitle7.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"7"];
        [intTitleArray addObject:str];
        textFreeTitle7.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld7.alpha = 1;
            swFreeFld7.alpha = 0;
            textFreeFld7.text = fld;
        } else {
            textFreeFld7.alpha = 0;
            swFreeFld7.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld7.on = YES;
            } else {
                swFreeFld7.on = NO;
            }
        }
    } else if([textFreeTitle8.text isEqualToString:@""]) {
        NSString *str = [NSString stringWithFormat:@"%@-%@", req, @"8"];
        [intTitleArray addObject:str];
        textFreeTitle8.text = title;
        if([div isEqualToString:@"0"]) {
            textFreeFld8.alpha = 1;
            swFreeFld8.alpha = 0;
            textFreeFld8.text = fld;
        } else {
            textFreeFld8.alpha = 0;
            swFreeFld8.alpha = 1;
            if([fld isEqualToString:@"1"]) {
                swFreeFld8.on = YES;
            } else {
                swFreeFld8.on = NO;
            }
        }
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
            textFreeFld1.enabled = false;
            textFreeFld2.enabled = false;
            textFreeFld3.enabled = false;
//202404 start
            textFreeFld4.enabled = false;
            textFreeFld5.enabled = false;
            textFreeFld6.enabled = false;
            textFreeFld7.enabled = false;
            textFreeFld8.enabled = false;
            swFreeFld1.enabled = false;
            swFreeFld2.enabled = false;
            swFreeFld3.enabled = false;
            swFreeFld4.enabled = false;
            swFreeFld5.enabled = false;
            swFreeFld6.enabled = false;
            swFreeFld7.enabled = false;
            swFreeFld8.enabled = false;
//202404 finish
            buttonDeleteDrivingStartYmd.enabled = false;
            buttonDeleteDrivingStartHm.enabled = false;
            buttonDeleteDrivingEndYmd.enabled = false;
            buttonDeleteDrivingEndHm.enabled = false;
            buttonSave.enabled = false;
            buttonSend.enabled = false;
            buttonDelete.enabled = false;

        }
        
    }
    
    if([textFreeTitle1.text isEqualToString:@""])
    {
        textFreeTitle1.hidden=YES;
        textFreeFld1.hidden=YES;
        swFreeFld1.hidden = YES;
    } else {
        textFreeTitle1.hidden=NO;
        textFreeFld1.hidden=NO;
        swFreeFld1.hidden = NO;
    }
    if([textFreeTitle2.text isEqualToString:@""])
    {
        textFreeTitle2.hidden=YES;
        textFreeFld2.hidden=YES;
        swFreeFld2.hidden = YES;
    } else {
        textFreeTitle2.hidden=NO;
        textFreeFld2.hidden=NO;
        swFreeFld2.hidden = NO;
    }
    if([textFreeTitle3.text isEqualToString:@""])
    {
        textFreeTitle3.hidden=YES;
        textFreeFld3.hidden=YES;
        swFreeFld3.hidden = YES;
    } else {
        textFreeTitle3.hidden=NO;
        textFreeFld3.hidden=NO;
        swFreeFld3.hidden = NO;
    }
//202404 start
    if([textFreeTitle4.text isEqualToString:@""])
    {
        textFreeTitle4.hidden=YES;
        textFreeFld4.hidden=YES;
        swFreeFld4.hidden = YES;
    } else {
        textFreeTitle4.hidden=NO;
        textFreeFld4.hidden=NO;
        swFreeFld4.hidden = NO;
    }
    if([textFreeTitle5.text isEqualToString:@""])
    {
        textFreeTitle5.hidden=YES;
        textFreeFld5.hidden=YES;
        swFreeFld5.hidden = YES;
    } else {
        textFreeTitle5.hidden=NO;
        textFreeFld5.hidden=NO;
        swFreeFld5.hidden = NO;
    }
    if([textFreeTitle6.text isEqualToString:@""])
    {
        textFreeTitle6.hidden=YES;
        textFreeFld6.hidden=YES;
        swFreeFld6.hidden = YES;
    } else {
        textFreeTitle6.hidden=NO;
        textFreeFld6.hidden=NO;
        swFreeFld6.hidden = NO;
    }
    if([textFreeTitle7.text isEqualToString:@""])
    {
        textFreeTitle7.hidden=YES;
        textFreeFld7.hidden=YES;
        swFreeFld7.hidden = YES;
    } else {
        textFreeTitle7.hidden=NO;
        textFreeFld7.hidden=NO;
        swFreeFld7.hidden = NO;
    }
    if([textFreeTitle8.text isEqualToString:@""])
    {
        textFreeTitle8.hidden=YES;
        textFreeFld8.hidden=YES;
        swFreeFld8.hidden = YES;
    } else {
        textFreeTitle8.hidden=NO;
        textFreeFld8.hidden=NO;
        swFreeFld8.hidden = NO;
    }
//202404 finish

}

- (NSString *)formatDateString:(NSString *)value
{
    if ([value isEqualToString:@""])
    {
        return @"";
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyyMMdd"];
    NSDate *date = [df dateFromString:value];
    
    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
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
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
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
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"HHmm"];
    NSDate *date = [df dateFromString:value];
    
    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
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
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
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

    [datePickerDrivingStartYmd addTarget:self action:@selector(updateDrivingStartYmd:) forControlEvents:UIControlEventValueChanged];
    // textFieldの入力をdatePickerに設定
    textDrivingStartYmd.inputView = datePickerDrivingStartYmd;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingStartYmd)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
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

    [datePickerDrivingStartHm addTarget:self action:@selector(updateDrivingStartHm:) forControlEvents:UIControlEventValueChanged];
    textDrivingStartHm.inputView = datePickerDrivingStartHm;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingStartHm)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
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

    [datePickerDrivingEndYmd addTarget:self action:@selector(updateDrivingEndYmd:) forControlEvents:UIControlEventValueChanged];
    textDrivingEndYmd.inputView = datePickerDrivingEndYmd;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingEndYmd)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
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

    [datePickerDrivingEndHm addTarget:self action:@selector(updateDrivingEndHm:) forControlEvents:UIControlEventValueChanged];
    textDrivingEndHm.inputView = datePickerDrivingEndHm;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneDrivingEndHm)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    textDrivingEndHm.inputAccessoryView = keyboardDoneButtonView;
}

- (void)createDrivingStartKmNumberPad
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlack;
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
    numberToolbar.barStyle = UIBarStyleBlack;
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
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [df stringFromDate:picker.date];
    textField.text = strDate;
}

-(void)updateTimePicker:(UIDatePicker *)picker :(UITextField *)textField
{
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
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
    else if ([textDrivingStartHm.text isEqualToString:@""])
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
//202404 start
    else if ([textFreeFld1.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle1.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld2.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle2.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld3.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle3.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld4.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle4.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld5.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle5.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld6.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle6.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld7.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle7.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
    else if ([textFreeFld8.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 255)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle8.text, @"が最大桁数を超えています"];
        errorMessage = str;
    }
//202404 finish
    else if ([textDrivingStartKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"乗務開始メータが最大桁数を超えています";
    }
    else if ([textDrivingEndKm.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8)
    {
        errorMessage = @"乗務終了メータが最大桁数を超えています";
    }

    
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
    
//202404 start
    
    if ([errorMessage isEqualToString:@""])
    {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *strTitle = [ud stringForKey:KEY_FREE_TITLE1];
        NSString *strReq = [ud stringForKey:KEY_FREE_REQUIRE1];
        NSString *strDiv = [ud stringForKey:KEY_FREE_DIVISION1];

        long cnt = [intTitleArray count];
        for(int i=0; i<cnt; i++){

            NSString *str = [intTitleArray objectAtIndex:i];
            NSString *str2 = [str substringToIndex:1];
            NSString *str3 = [str substringWithRange:NSMakeRange(2,1)];

            if ([str2 isEqualToString:@"1"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE1];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE1];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION1];
                } else {
                    strTitle = drivingReport.free_title1;
                    strReq = drivingReport.free_req1;
                    strDiv = drivingReport.free_div1;
                }
            } else if ([str2 isEqualToString:@"2"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE2];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE2];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION2];
                } else {
                    strTitle = drivingReport.free_title2;
                    strReq = drivingReport.free_req2;
                    strDiv = drivingReport.free_div2;
                }
            } else if ([str2 isEqualToString:@"3"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE3];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE3];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION3];
                } else {
                    strTitle = drivingReport.free_title3;
                    strReq = drivingReport.free_req3;
                    strDiv = drivingReport.free_div3;
                }
            } else if ([str2 isEqualToString:@"4"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE4];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE4];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION4];
                } else {
                    strTitle = drivingReport.free_title4;
                    strReq = drivingReport.free_req4;
                    strDiv = drivingReport.free_div4;
                }
            } else if ([str2 isEqualToString:@"5"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE5];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE5];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION5];
                } else {
                    strTitle = drivingReport.free_title5;
                    strReq = drivingReport.free_req5;
                    strDiv = drivingReport.free_div5;
                }
            } else if ([str2 isEqualToString:@"6"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE6];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE6];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION6];
                } else {
                    strTitle = drivingReport.free_title6;
                    strReq = drivingReport.free_req6;
                    strDiv = drivingReport.free_div6;
                }
            } else if ([str2 isEqualToString:@"7"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE7];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE7];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION7];
                } else {
                    strTitle = drivingReport.free_title7;
                    strReq = drivingReport.free_req7;
                    strDiv = drivingReport.free_div7;
                }
            } else if ([str2 isEqualToString:@"8"]) {
                if (drivingReport == nil)
                {
                    strTitle = [ud stringForKey:KEY_FREE_TITLE8];
                    strReq = [ud stringForKey:KEY_FREE_REQUIRE8];
                    strDiv = [ud stringForKey:KEY_FREE_DIVISION8];
                } else {
                    strTitle = drivingReport.free_title8;
                    strReq = drivingReport.free_req8;
                    strDiv = drivingReport.free_div8;
                }
            }

            if (![strTitle isEqualToString:@""] && [strReq isEqualToString:@"1"] )
            {
                if ([str3 isEqualToString:@"1"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld1.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld1.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle1.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"2"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld2.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld2.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle2.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"3"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld3.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld3.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle3.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"4"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld4.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld4.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle4.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"5"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld5.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld5.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle5.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"6"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld6.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld6.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle6.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"7"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld7.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld7.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle7.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                } else if ([str3 isEqualToString:@"8"]) {
                    if (([strDiv isEqualToString:@"0"] && [textFreeFld8.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 0) ||
                        ([strDiv isEqualToString:@"1"] && swFreeFld8.on == NO))
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%@",textFreeTitle8.text, @"を入力して下さい"];
                        errorMessage = str;
                        break;
                    }
                }

            }

        }
    }
    
//202404 finish

    if (![errorMessage isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:errorMessage
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
       {
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
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

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
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
    
    RLMRealm *realm = [RLMRealm defaultRealm];
/*
    if ([self CheckData] == false)
    {
        return NO;
    }
 */

    [realm beginWriteTransaction];
    bool newrecord= false;
    if (drivingReport == nil)
    {
        newrecord = true;

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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *company = [ud stringForKey:KEY_COMPANY];
    drivingReport.company_code = company;
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
    
//202404 start
    drivingReport.free_title1 = @"";
    drivingReport.free_title2 = @"";
    drivingReport.free_title3 = @"";
    drivingReport.free_title4 = @"";
    drivingReport.free_title5 = @"";
    drivingReport.free_title6 = @"";
    drivingReport.free_title7 = @"";
    drivingReport.free_title8 = @"";
    drivingReport.free_fld1 = @"";
    drivingReport.free_fld2 = @"";
    drivingReport.free_fld3 = @"";
    drivingReport.free_fld4 = @"";
    drivingReport.free_fld5 = @"";
    drivingReport.free_fld6 = @"";
    drivingReport.free_fld7 = @"";
    drivingReport.free_fld8 = @"";
    
    long cnt = [intTitleArray count];
    for(int i=0; i<cnt; i++){
        
        NSString *str = [intTitleArray objectAtIndex:i];
        NSString *str2 = [str substringToIndex:1];
        NSString *str3 = [str substringWithRange:NSMakeRange(2,1)];

        NSString *title = @"";
        NSString *fld = @"";
        NSString *div = @"";
        

        if ([str2 isEqualToString:@"1"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION1];
            } else {
                div = drivingReport.free_div1;
            }
        } else if ([str2 isEqualToString:@"2"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION2];
            } else {
                div = drivingReport.free_div2;
            }
        } else if ([str2 isEqualToString:@"3"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION3];
            } else {
                div = drivingReport.free_div3;
            }
        } else if ([str2 isEqualToString:@"4"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION4];
            } else {
                div = drivingReport.free_div4;
            }
        } else if ([str2 isEqualToString:@"5"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION5];
            } else {
                div = drivingReport.free_div5;
            }
        } else if ([str2 isEqualToString:@"6"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION6];
            } else {
                div = drivingReport.free_div6;
            }
        } else if ([str2 isEqualToString:@"7"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION7];
            } else {
                div = drivingReport.free_div7;
            }
        } else if ([str2 isEqualToString:@"8"]) {
            if(newrecord) {
                div = [ud stringForKey:KEY_FREE_DIVISION8];
            } else {
                div = drivingReport.free_div8;
            }
        }
        
        if ([str3 isEqualToString:@"1"]) {
            title = textFreeTitle1.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld1.text;
            } else {
                if(swFreeFld1.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"2"]) {
            title = textFreeTitle2.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld2.text;
            } else {
                if(swFreeFld2.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"3"]) {
            title = textFreeTitle3.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld3.text;
            } else {
                if(swFreeFld3.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"4"]) {
            title = textFreeTitle4.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld4.text;
            } else {
                if(swFreeFld4.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"5"]) {
            title = textFreeTitle5.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld5.text;
            } else {
                if(swFreeFld5.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"6"]) {
            title = textFreeTitle6.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld6.text;
            } else {
                if(swFreeFld6.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"7"]) {
            title = textFreeTitle7.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld7.text;
            } else {
                if(swFreeFld7.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        } else if ([str3 isEqualToString:@"8"]) {
            title = textFreeTitle8.text;
            if ([div isEqualToString:@"0"])
            {
                fld = textFreeFld8.text;
            } else {
                if(swFreeFld8.on == YES) {
                    fld = @"1";
                } else {
                    fld = @"0";
                }
            }
        }
        
        if ([str2 isEqualToString:@"1"]) {
            drivingReport.free_title1 = title;
            drivingReport.free_fld1 = fld;
        } else if([str2 isEqualToString:@"2"]) {
            drivingReport.free_title2 = title;
            drivingReport.free_fld2 = fld;
        } else if([str2 isEqualToString:@"3"]) {
            drivingReport.free_title3 = title;
            drivingReport.free_fld3 = fld;
        } else if([str2 isEqualToString:@"4"]) {
            drivingReport.free_title4 = title;
            drivingReport.free_fld4 = fld;
        } else if([str2 isEqualToString:@"5"]) {
            drivingReport.free_title5 = title;
            drivingReport.free_fld5 = fld;
        } else if([str2 isEqualToString:@"6"]) {
            drivingReport.free_title6 = title;
            drivingReport.free_fld6 = fld;
        } else if([str2 isEqualToString:@"7"]) {
            drivingReport.free_title7 = title;
            drivingReport.free_fld7 = fld;
        } else if([str2 isEqualToString:@"8"]) {
            drivingReport.free_title8 = title;
            drivingReport.free_fld8 = fld;
        }
    }

    if(newrecord) {
        drivingReport.free_div1 = [ud stringForKey:KEY_FREE_DIVISION1];
        drivingReport.free_div2 = [ud stringForKey:KEY_FREE_DIVISION2];
        drivingReport.free_div3 = [ud stringForKey:KEY_FREE_DIVISION3];
        drivingReport.free_div4 = [ud stringForKey:KEY_FREE_DIVISION4];
        drivingReport.free_div5 = [ud stringForKey:KEY_FREE_DIVISION5];
        drivingReport.free_div6 = [ud stringForKey:KEY_FREE_DIVISION6];
        drivingReport.free_div7 = [ud stringForKey:KEY_FREE_DIVISION7];
        drivingReport.free_div8 = [ud stringForKey:KEY_FREE_DIVISION8];
        
        drivingReport.free_req1 = [ud stringForKey:KEY_FREE_REQUIRE1];
        drivingReport.free_req2 = [ud stringForKey:KEY_FREE_REQUIRE2];
        drivingReport.free_req3 = [ud stringForKey:KEY_FREE_REQUIRE3];
        drivingReport.free_req4 = [ud stringForKey:KEY_FREE_REQUIRE4];
        drivingReport.free_req5 = [ud stringForKey:KEY_FREE_REQUIRE5];
        drivingReport.free_req6 = [ud stringForKey:KEY_FREE_REQUIRE6];
        drivingReport.free_req7 = [ud stringForKey:KEY_FREE_REQUIRE7];
        drivingReport.free_req8 = [ud stringForKey:KEY_FREE_REQUIRE8];
    } else {
        
    }
//202404 finish

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
     
     if ([self CheckData])
     {
         if ([self SaveData] == false)
         {
             buttonSend.enabled = true;
             return;
         }
         
         retryCount = 0;
         [self sendData];
         
         buttonSend.enabled = false;
     }
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
    [headerJson setObject:drivingReport.free_title1 forKey:@"free_title1"];
    [headerJson setObject:drivingReport.free_title2 forKey:@"free_title2"];
    [headerJson setObject:drivingReport.free_title3 forKey:@"free_title3"];
    [headerJson setObject:drivingReport.free_fld1 forKey:@"free_fld1"];
    [headerJson setObject:drivingReport.free_fld2 forKey:@"free_fld2"];
    [headerJson setObject:drivingReport.free_fld3 forKey:@"free_fld3"];
//202404 start
    [headerJson setObject:drivingReport.free_title4 forKey:@"free_title4"];
    [headerJson setObject:drivingReport.free_title5 forKey:@"free_title5"];
    [headerJson setObject:drivingReport.free_title6 forKey:@"free_title6"];
    [headerJson setObject:drivingReport.free_title7 forKey:@"free_title7"];
    [headerJson setObject:drivingReport.free_title8 forKey:@"free_title8"];
    [headerJson setObject:drivingReport.free_fld4 forKey:@"free_fld4"];
    [headerJson setObject:drivingReport.free_fld5 forKey:@"free_fld5"];
    [headerJson setObject:drivingReport.free_fld6 forKey:@"free_fld6"];
    [headerJson setObject:drivingReport.free_fld7 forKey:@"free_fld7"];
    [headerJson setObject:drivingReport.free_fld8 forKey:@"free_fld8"];
    [headerJson setObject:drivingReport.free_div1 forKey:@"free_div1"];
    [headerJson setObject:drivingReport.free_div2 forKey:@"free_div2"];
    [headerJson setObject:drivingReport.free_div3 forKey:@"free_div3"];
    [headerJson setObject:drivingReport.free_div4 forKey:@"free_div4"];
    [headerJson setObject:drivingReport.free_div5 forKey:@"free_div5"];
    [headerJson setObject:drivingReport.free_div6 forKey:@"free_div6"];
    [headerJson setObject:drivingReport.free_div7 forKey:@"free_div7"];
    [headerJson setObject:drivingReport.free_div8 forKey:@"free_div8"];
    [headerJson setObject:drivingReport.free_req1 forKey:@"free_req1"];
    [headerJson setObject:drivingReport.free_req2 forKey:@"free_req2"];
    [headerJson setObject:drivingReport.free_req3 forKey:@"free_req3"];
    [headerJson setObject:drivingReport.free_req4 forKey:@"free_req4"];
    [headerJson setObject:drivingReport.free_req5 forKey:@"free_req5"];
    [headerJson setObject:drivingReport.free_req6 forKey:@"free_req6"];
    [headerJson setObject:drivingReport.free_req7 forKey:@"free_req7"];
    [headerJson setObject:drivingReport.free_req8 forKey:@"free_req8"];
//202404 finish
    
    NSMutableArray *detailJsonArray = [NSMutableArray array];
    for (RealmLocalDataDrivingReportDetail *detail in drivingReportDetailList)
    {
        NSMutableDictionary *detailJson = [NSMutableDictionary dictionary];
        [detailJson setObject:[NSString stringWithFormat:@"%d", detail._id] forKey:@"id"];
        [detailJson setObject:[NSString stringWithFormat:@"%d", detail.driving_report_id] forKey:@"driving_report_id"];
        [detailJson setObject:detail.destination forKey:@"destination"];
        [detailJson setObject:detail.driving_start_hm forKey:@"driving_start_hm"];
        [detailJson setObject:[NSString stringWithFormat:@"%.0f", detail.driving_start_km] forKey:@"driving_start_km"];
        [detailJson setObject:detail.driving_end_hm forKey:@"driving_end_hm"];
        [detailJson setObject:[NSString stringWithFormat:@"%.0f", detail.driving_end_km] forKey:@"driving_end_km"];
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
