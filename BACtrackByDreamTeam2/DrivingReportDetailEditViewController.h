//
//  DrivingReportDetailEditViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/06.
//

#import <UIKit/UIKit.h>
#import "DrivingReportDestinationViewController.h"

@interface DrivingReportDetailEditViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *contentsView;
    IBOutlet UITextField *textDestination;
    IBOutlet UITextField *textDrivingStartHm;
    IBOutlet UITextField *textDrivingStartKm;
    IBOutlet UITextField *textDrivingEndHm;
    IBOutlet UITextField *textDrivingEndKm;
    IBOutlet UITextField *textCargoWeight;
    IBOutlet UITextField *textCargoStatus;
    IBOutlet UITextField *textNote;
    
    IBOutlet UIButton *buttonDestinationSelect;
    IBOutlet UIButton *buttonDeleteDrivingStartHm;
    IBOutlet UIButton *buttonDeleteDrivingEndHm;
    IBOutlet UIButton *buttonSave;
    IBOutlet UIButton *buttonDelete;
    
    DrivingReportDestinationViewController *drivingReportDestinationViewController;
}
- (IBAction)buttonDestinationSelectTouchUpInside:(id)sender;

- (IBAction)buttonDeleteStartHmTouchUpInside:(id)sender;
- (IBAction)buttonDeleteEndHmTouchUpInside:(id)sender;

- (IBAction)buttonSaveTouchUpInside:(id)sender;
- (IBAction)buttonDeleteTouchUpInside:(id)sender;

- (void)setDestination:(NSString *)destination;

@property int driving_report_id;
@property int driving_report_detail_id;

@end
