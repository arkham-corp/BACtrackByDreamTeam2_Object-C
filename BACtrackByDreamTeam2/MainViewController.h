//
//  MainViewController.h
//  BACtrackByDreamTeam
//
//  Created by COM-MAC on 2016/01/15.
//  Copyright © 2016年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyViewController.h"
#import "AgreementViewController.h"
#import "Reachability.h"

@interface MainViewController : UIViewController
{
    CompanyViewController *companyViewController;
    __weak IBOutlet UIButton *buttonExec;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
