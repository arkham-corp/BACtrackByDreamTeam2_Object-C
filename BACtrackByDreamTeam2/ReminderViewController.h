//
//  ReminderViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface ReminderViewController : UIViewController
{
    IBOutlet UITextField *textStartYmd;
    IBOutlet UITextField *textStartHm;
    IBOutlet UIButton *buttonDeleteStartYmd;
    IBOutlet UIButton *buttonDeleteStartHm;
    IBOutlet UIButton *buttonExec;
    
}

- (IBAction)btnExecTouchUpInside:(id)sender;

@end
