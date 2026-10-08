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
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Network/Network.h>

@interface MainViewController : UIViewController
    <NSURLSessionDataDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate>
{
    CompanyViewController *companyViewController;
    nw_connection_t _localNetworkConnection;
    __weak IBOutlet UILabel *labelAppVer;
    __weak IBOutlet UILabel *labelSchemaVer;
    __weak IBOutlet UIButton *buttonExec;
    // 各権限の結果を記録
    BOOL _cameraGranted;
    BOOL _locationGranted;
    BOOL _bluetoothGranted;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

- (IBAction)btnDecisionTouchUpInside:(id)sender;

@end
