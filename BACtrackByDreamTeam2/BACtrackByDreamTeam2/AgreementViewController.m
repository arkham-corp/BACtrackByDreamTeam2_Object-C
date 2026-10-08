//
//  AgreementViewController.m
//  BACtrackByDreamTeam
//
//  Created by COM-MAC on 2016/01/15.
//  Copyright © 2016年 COM-MAC. All rights reserved.
//

#import "AgreementViewController.h"
#import "AppConsts.h"

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"利用規約"];
    
    _buttonAgree.exclusiveTouch = true;
    _buttonNotAgree.exclusiveTouch = true;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnTouchUpInsideAgree:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:@"1" forKey:KEY_AGREEMENT];
    [ud synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completionHandler) {
            self.completionHandler(YES);  // 同意
        }
    }];
}

- (IBAction)btnTouchUpInsideNotAgree:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completionHandler) {
            self.completionHandler(NO);  // 不同意
        }
    }];
}
@end
