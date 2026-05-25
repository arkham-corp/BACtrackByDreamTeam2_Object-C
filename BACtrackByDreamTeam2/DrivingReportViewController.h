//
//  DrivingReportViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import <UIKit/UIKit.h>
#import "DrivingReportEditViewController.h"

@interface DrivingReportViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *mTableView;
    __weak IBOutlet UIButton *buttonAdd;
    DrivingReportEditViewController *drivingReportEditViewController;
}

- (IBAction)btnAddTouchUpInside:(id)sender;

@end
