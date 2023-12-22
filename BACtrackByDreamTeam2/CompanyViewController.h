//
//  CompanyViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/11/02.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "GPSViewController.h"
#import "Reachability.h"

@interface CompanyViewController : UIViewController <UITextFieldDelegate>
{
    MenuViewController *menuViewController;
    GPSViewController *gpsViewController;
    IBOutlet UITextField *numberTextField;
    __weak IBOutlet UIButton *buttonExec;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
