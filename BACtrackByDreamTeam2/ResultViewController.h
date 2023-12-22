//
//  ResultViewController.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/09.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface ResultViewController : UIViewController
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblResult;
    IBOutlet UILabel *lblDrivingDiv;
    __weak IBOutlet UILabel *lblSending;
    __weak IBOutlet UILabel *lblRemoval;
    __weak IBOutlet UILabel *lblMessage;
    __weak IBOutlet UIButton *btnEnd;
}

@end
