//
//  ReminderViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import "ReminderViewController.h"

@interface ReminderViewController ()
{
    UIDatePicker* datePickerStartYmd;
    UIDatePicker* datePickerStartHm;
}
@end

@implementation ReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->buttonExec.enabled = true;

    [self createStartYmdPicker];
    [self createStartHmPicker];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [df stringFromDate:now];
    textStartYmd.text = strDate;
    
    if([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized) {
        // リマインダーにアクセスできる場合
    } else {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        
        if (@available(iOS 17.0, *)) {
            [eventStore requestFullAccessToRemindersWithCompletion:^(BOOL granted, NSError *error) {
                if(granted) {
                    // はじめてリマインダーにアクセスする場合にアラートが表示されて、OKした場合にここにくるよ
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // アクセス権がありません。
                        // "プライバシー設定"でアクセスを有効にできます。
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"アプリはリマインダーにアクセス出来ません" message:@"[設定]->[プライバシー・・・]からリマインダーにアプリがアクセス出来るように設定してください" preferredStyle:UIAlertControllerStyleAlert];
                        
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                            {
                                self->buttonExec.enabled = false;
                            }]];
                        
                            [self presentViewController:alert animated:YES completion:nil];
                        
                        });
                    }
                }
            ];
            
        } else {
            [eventStore requestAccessToEntityType:EKEntityTypeReminder
                     completion:^(BOOL granted, NSError *error) {
                if(granted) {
                    // はじめてリマインダーにアクセスする場合にアラートが表示されて、OKした場合にここにくるよ
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // アクセス権がありません。
                        // "プライバシー設定"でアクセスを有効にできます。
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This app does not have access to you reminders." message:@"To display your reminder, enable [YOUR APP] in the \"Privacy\" → \"Reminders\" in the Settings.app." preferredStyle:UIAlertControllerStyleAlert];
                        
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                            {
                                self->buttonExec.enabled = false;
                            }]];
                        
                            [self presentViewController:alert animated:YES completion:nil];
                        
                        });
                    }
                }
            ];
        }
    }
    


    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self setControlEnable];

}

- (void)setControlEnable
{
}

- (void)createStartYmdPicker
{
    // DatePickerの設定
    datePickerStartYmd = [[UIDatePicker alloc]init];
    
    [datePickerStartYmd setDatePickerMode:UIDatePickerModeDate];
    if (@available(iOS 13.4, *)) {
        [datePickerStartYmd setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerStartYmd addTarget:self action:@selector(updateStartYmd:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textStartYmd.inputView = datePickerStartYmd;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneStartYmd)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textStartYmd.inputAccessoryView = keyboardDoneButtonView;
}

- (void)createStartHmPicker
{
    // DatePickerの設定
    datePickerStartHm = [[UIDatePicker alloc]init];
    
    [datePickerStartHm setDatePickerMode:UIDatePickerModeTime];
    if (@available(iOS 13.4, *)) {
        [datePickerStartHm setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    } else {
        // Fallback on earlier versions
    }

    // DatePickerを編集したら、updateTextFieldを呼び出す
    [datePickerStartHm addTarget:self action:@selector(updateStartHm:) forControlEvents:UIControlEventValueChanged];

    // textFieldの入力をdatePickerに設定
    textStartHm.inputView = datePickerStartHm;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle    = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneStartHm)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textStartHm.inputAccessoryView = keyboardDoneButtonView;
}

- (IBAction)buttonDeleteStartYmdTouchUpInside:(id)sender {
    textStartYmd.text = @"";
}

- (IBAction)buttonDeleteStartHmTouchUpInside:(id)sender {
    textStartHm.text = @"";
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

-(void)updateStartYmd:(id)sender
{
    [self updateDatePicker:sender :textStartYmd];
}

-(void)updateStartHm:(id)sender
{
    [self updateTimePicker:sender :textStartHm];
}

-(void)pickerDoneStartYmd
{
    [self updateDatePicker:datePickerStartYmd :textStartYmd];
    [self.view endEditing:YES];
}

-(void)pickerDoneStartHm
{
    [self updateTimePicker:datePickerStartHm :textStartHm];
    [self.view endEditing:YES];
}

- (IBAction)btnExecTouchUpInside:(id)sender {
    
    self->buttonExec.enabled = false;
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
    reminder.title = @"アルコール測定時間です";
    reminder.calendar = [eventStore defaultCalendarForNewReminders];

    NSString *ymd = [textStartYmd.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *hm = [textStartHm.text stringByReplacingOccurrencesOfString:@":" withString:@""];

    if (![ymd isEqualToString:@""] && ![hm isEqualToString:@""])
    {
        NSString *y =[ymd substringWithRange:NSMakeRange(0, 4)];
        NSString *m =[ymd substringWithRange:NSMakeRange(4, 2)];
        NSString *d =[ymd substringWithRange:NSMakeRange(6, 2)];
        NSString *h =[hm substringWithRange:NSMakeRange(0, 2)];
        NSString *mm =[hm substringWithRange:NSMakeRange(2, 2)];

        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:[y intValue] ];
        [dateComponents setMonth:[m intValue]];
        [dateComponents setDay:[d intValue]];
        [dateComponents setHour:[h intValue]];
        [dateComponents setMinute:[mm intValue]];
        [dateComponents setSecond:0];
        reminder.dueDateComponents = dateComponents;
        // 通知を追加
        [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:[[NSCalendar currentCalendar] dateFromComponents:dateComponents]]];

        NSError *error;
        if(![eventStore saveReminder:reminder commit:YES error:&error]) 
        {
            NSLog(@"%@", error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー" message:@"設定出来ませんでした" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"設定しました" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    self->buttonExec.enabled = true;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
