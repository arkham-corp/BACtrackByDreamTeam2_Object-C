//
//  AgreementViewController.h
//  BACtrackByDreamTeam
//
//  Created by COM-MAC on 2016/01/15.
//  Copyright © 2016年 COM-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonAgree;
@property (weak, nonatomic) IBOutlet UIButton *buttonNotAgree;

- (IBAction)btnTouchUpInsideAgree:(id)sender;
- (IBAction)btnTouchUpInsideNotAgree:(id)sender;

@property (nonatomic, copy) void (^completionHandler)(BOOL agreed);

@end
