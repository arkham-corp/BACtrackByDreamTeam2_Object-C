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

@interface MainViewController : UIViewController
{
    CompanyViewController *companyViewController;
    __weak IBOutlet UILabel *labelAppVer;
    __weak IBOutlet UILabel *labelSchemaVer;
    __weak IBOutlet UIButton *buttonExec;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
