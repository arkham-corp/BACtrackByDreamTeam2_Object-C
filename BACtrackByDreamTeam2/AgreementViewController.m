//
//  AgreementViewController.m
//  BACtrackByDreamTeam
//
//  Created by COM-MAC on 2016/01/15.
//  Copyright © 2016年 COM-MAC. All rights reserved.
//

#import "AgreementViewController.h"
#import "AppConsts.h"

@interface AgreementViewController ()
{
    BacTrackAPI *mBacTrack;
}
@end

@implementation AgreementViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"利用規約"];
    
    _buttonAgree.exclusiveTouch = true;
    _buttonNotAgree.exclusiveTouch = true;
    
    mBacTrack = [[BacTrackAPI alloc] initWithDelegate:delegate AndAPIKey:@"e10582efcaf64f7d90d947c2899b43"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnTouchUpInsideAgree:(id)sender {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:@"1" forKey:KEY_AGREEMENT];
    [ud synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnTouchUpInsideNotAgree:(id)sender {
    exit(0);
}

@end
