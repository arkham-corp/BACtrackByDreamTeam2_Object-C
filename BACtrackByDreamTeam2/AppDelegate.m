//
//  AppDelegate.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/04.
//  Copyright (c) 2020年 COM-MAC. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConsts.h"
#import "MainViewController.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReport.h"
#import "RealmLocalDataDrivingReportDetail.h"
#import "RealmLocalDataDrivingReportDestination.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Realmの初期化
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion=100;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    if ([CAREATE_TEST_DATA_FLG isEqualToString:@"1"])
    {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        
        [self createDummyData:realm];
        
        [realm commitWriteTransaction];
    }
    
    // 保存値クリア
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:KEY_LOCATION_ADDRESS];
    [ud removeObjectForKey:KEY_LOCATION_LATITUDE];
    [ud removeObjectForKey:KEY_LOCATION_LONGITUDE];
    [ud removeObjectForKey:KEY_ALCOHOL_VALUE];
    [ud removeObjectForKey:KEY_ALCOHOL_VALUE_DIV];
    [ud removeObjectForKey:KEY_PHOTO];
    [ud removeObjectForKey:KEY_INSPECTION_TIME];
    [ud removeObjectForKey:KEY_BREATHALYZER_UUID];
    [ud synchronize];
    
    // ナビゲーションバーの背景色を設定する
    UINavigationBar *navibar = [UINavigationBar appearance];
    navibar.backgroundColor = [UIColor whiteColor]; // 白色
    navibar.barTintColor = [UIColor whiteColor]; // 白色
    
    MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    self.navigationControl = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.navigationControl setNavigationBarHidden:NO animated:NO];
    [self.navigationControl setToolbarHidden:YES animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationControl;
    [self.window addSubview:self.navigationControl.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)createDummyData:(RLMRealm *)realm {
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    
    for(int i=0; i<10; i++)
    {
        NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(i*-1)*24*60*60];
        
        int nextId = 1;
        
        NSNumber *maxId = [[RealmLocalDataDrivingReport allObjectsInRealm:realm] maxOfProperty:@"_id"];
        if (maxId != nil)
        {
            nextId = [maxId intValue] + 1;
        }
        
        RealmLocalDataDrivingReport *drivingReport = [[RealmLocalDataDrivingReport alloc] init];
        drivingReport._id = nextId;
        drivingReport.company_code=@"developer";
        drivingReport.driver_code = @"100";
        drivingReport.car_number = @"1234";
        drivingReport.driving_start_ymd = [df stringFromDate:targetDate];
        drivingReport.driving_start_hm = @"0830";
        drivingReport.driving_start_km = 10000;
        drivingReport.driving_end_ymd = [df stringFromDate:targetDate];
        drivingReport.driving_end_hm = @"1730";
        drivingReport.driving_end_km = 10500;
        if (i == 0 || i == 1)
        {
            drivingReport.send_flg = @"0";
        }
        else
        {
            drivingReport.send_flg = @"1";
        }
        [realm addObject:drivingReport];
        
        for(int j=0; j<3; j++)
        {
            nextId = 1;
            
            maxId = [[RealmLocalDataDrivingReportDetail allObjectsInRealm:realm] maxOfProperty:@"_id"];
            if (maxId != nil)
            {
                nextId = [maxId intValue] + 1;
            }
            
            RealmLocalDataDrivingReportDetail *drivingReportDetail = [[RealmLocalDataDrivingReportDetail alloc] init];
            drivingReportDetail._id = nextId;
            drivingReportDetail.driving_report_id =drivingReport._id;
            drivingReportDetail.destination = [NSString stringWithFormat:@"%@%d", @"行先", j];
            if (j == 0)
            {
                drivingReportDetail.driving_start_hm = @"0900";
                drivingReportDetail.driving_end_hm = @"1200";
                drivingReportDetail.driving_start_km = 10000;
                drivingReportDetail.driving_end_km = 10100;
            }
            else if (j == 1)
            {
                drivingReportDetail.driving_start_hm = @"1200";
                drivingReportDetail.driving_end_hm = @"1500";
                drivingReportDetail.driving_start_km = 10100;
                drivingReportDetail.driving_end_km = 10300;
            }
            else if (j == 2)
            {
                drivingReportDetail.driving_start_hm = @"1500";
                drivingReportDetail.driving_end_hm = @"1700";
                drivingReportDetail.driving_start_km = 10300;
                drivingReportDetail.driving_end_km = 10500;
            }
            drivingReportDetail.cargo_weight = @"";
            drivingReportDetail.cargo_status = @"";
            drivingReportDetail.note = @"";
            
            [realm addObject:drivingReportDetail];
        }
    }
    
    // 行先
    RealmLocalDataDrivingReportDestination *drivingReportDestination1 = [[RealmLocalDataDrivingReportDestination alloc] init];
    drivingReportDestination1._id = 1;
    drivingReportDestination1.destination = @"A";
    drivingReportDestination1.company_code = @"developer";
    [realm addObject:drivingReportDestination1];
    
    RealmLocalDataDrivingReportDestination *drivingReportDestination2 = [[RealmLocalDataDrivingReportDestination alloc] init];
    drivingReportDestination2._id = 2;
    drivingReportDestination2.destination = @"C";
    drivingReportDestination2.company_code = @"developer";
    [realm addObject:drivingReportDestination2];
    
    RealmLocalDataDrivingReportDestination *drivingReportDestination3 = [[RealmLocalDataDrivingReportDestination alloc] init];
    drivingReportDestination3._id = 3;
    drivingReportDestination3.destination = @"B";
    drivingReportDestination3.company_code = @"developer";
    [realm addObject:drivingReportDestination3];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

