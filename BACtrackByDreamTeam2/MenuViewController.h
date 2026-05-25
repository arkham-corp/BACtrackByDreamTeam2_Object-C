//
//  MenuViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/16.
//

#import <UIKit/UIKit.h>
#import "GPSViewController.h"
#import "DrivingReportViewController.h"
#import "SendListViewController.h"
#import "ReminderViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewController : UIViewController
{
    GPSViewController *gpsViewController;
    DrivingReportViewController *drivingReportViewController;
    SendListViewController *sendListViewController;
    ReminderViewController *reminderViewController;
    __weak IBOutlet UIButton *buttonInspection;
    __weak IBOutlet UIButton *buttonDrivingReport;
    __weak IBOutlet UIButton *buttonSendList;
    __weak IBOutlet UIButton *buttonReminder;
}

- (IBAction)btnInspectionTouchUpInside:(id)sender;
- (IBAction)btnDrivinngReportTouchUpInside:(id)sender;
- (IBAction)btnSendListTouchUpInside:(id)sender;
- (IBAction)btnReminderTouchUpInside:(id)sender;

@end

NS_ASSUME_NONNULL_END
