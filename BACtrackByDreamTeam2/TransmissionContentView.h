//
//  TransmissionContentView.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/15.
//
#import <UIKit/UIKit.h>
#import "DrivingReportDetailViewController.h"

@interface TransmissionContentView : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *contentsView;
    IBOutlet UITextField *textInspectionTime;
    IBOutlet UITextField *textInspectionYmd;
    IBOutlet UITextField *textInspectionHm;
    IBOutlet UITextField *textDriverCode;
    IBOutlet UITextField *textCarNumber;
    IBOutlet UITextField *textLocationName;
    IBOutlet UITextField *textLocationLat;
    IBOutlet UITextField *textLocationLong;
    IBOutlet UITextView *textLocation;
    IBOutlet UITextField *textDrivingDiv;
    IBOutlet UITextField *textAlcoholValue;
    IBOutlet UITextField *textBacktrackId;
    IBOutlet UITextField *textUseNumber;
    IBOutlet UITextField *textSendFlg;
    IBOutlet UIImageView* imageView;

    IBOutlet UIButton *buttonSend;
}

- (IBAction)buttonSendTouchUpInside:(id)sender;

@property int _id;

@end
