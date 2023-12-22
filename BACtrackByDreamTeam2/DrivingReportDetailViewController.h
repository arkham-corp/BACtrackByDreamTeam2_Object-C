//
//  DrivingReportDetailViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/04.
//

#import <UIKit/UIKit.h>
#import "DrivingReportDetailEditViewController.h"

@interface DrivingReportDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *mTableView;
    __weak IBOutlet UIButton *buttonAdd;
    DrivingReportDetailEditViewController *drivingReportDetailEditViewController;
}
@property int driving_report_id;

- (IBAction)btnAddTouchUpInside:(id)sender;

@end
