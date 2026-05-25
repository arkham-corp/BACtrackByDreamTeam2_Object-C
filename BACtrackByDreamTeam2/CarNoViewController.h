//
//  CarNoViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionViewController.h"

@interface CarNoViewController : UIViewController <UITextFieldDelegate>
{
    InspectionViewController *inspectionViewController;
    IBOutlet UITextField *numberTextField;
    __weak IBOutlet UIButton *buttonExec;
}

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
