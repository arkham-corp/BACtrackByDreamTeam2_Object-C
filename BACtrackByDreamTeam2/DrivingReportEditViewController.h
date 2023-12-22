//
//  DrivingReportEditViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/27.
//

#import <UIKit/UIKit.h>
#import "DrivingReportDetailViewController.h"

@interface DrivingReportEditViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *contentsView;
    IBOutlet UITextField *textDriverCode;
    IBOutlet UITextField *textCarNumber;
    IBOutlet UITextField *textDrivingStartYmd;
    IBOutlet UITextField *textDrivingStartHm;
    IBOutlet UITextField *textDrivingEndYmd;
    IBOutlet UITextField *textDrivingEndHm;
    IBOutlet UITextField *textDrivingStartKm;
    IBOutlet UITextField *textDrivingEndKm;
    IBOutlet UITextField *textResuelingStatus;
    IBOutlet UITextField *textAbnormalReport;
    IBOutlet UITextField *textInstruction;
    IBOutlet UITextField *textFreeFld1;
    IBOutlet UITextField *textFreeFld2;
    IBOutlet UITextField *textFreeFld3;
    IBOutlet UILabel *textFreeTitle1;
    IBOutlet UILabel *textFreeTitle2;
    IBOutlet UILabel *textFreeTitle3;

    IBOutlet UIButton *buttonDeleteDrivingStartYmd;
    IBOutlet UIButton *buttonDeleteDrivingStartHm;
    IBOutlet UIButton *buttonDeleteDrivingEndYmd;
    IBOutlet UIButton *buttonDeleteDrivingEndHm;
    IBOutlet UIButton *buttonSave;
    IBOutlet UIButton *buttonDetail;
    IBOutlet UIButton *buttonSend;
    IBOutlet UIButton *buttonDelete;
    DrivingReportDetailViewController *drivingReportDetailViewController;
}
- (IBAction)buttonDeleteStartYmdTouchUpInside:(id)sender;
- (IBAction)buttonDeleteStartHmTouchUpInside:(id)sender;
- (IBAction)buttonDeleteEndYmdTouchUpInside:(id)sender;
- (IBAction)buttonDeleteEndHmTouchUpInside:(id)sender;

- (IBAction)buttonSaveTouchUpInside:(id)sender;
- (IBAction)buttonDetailTouchUpInside:(id)sender;
- (IBAction)buttonSendTouchUpInside:(id)sender;
- (IBAction)buttonDeleteTouchUpInside:(id)sender;

@property int _id;

@end

