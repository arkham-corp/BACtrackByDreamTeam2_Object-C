//
//  AppDelegate.m
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/04.
//  Copyright (c) 2020年 COM-MAC. All rights reserved.
//

#import "AppDelegate.h"
#import "Realm/Realm.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Realmの初期化
    self.realmSchemaVer = 2;
    
    @try {
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.schemaVersion = self.realmSchemaVer;
        config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
            // Migration処理
        };
        [RLMRealmConfiguration setDefaultConfiguration:config];
        [RLMRealm defaultRealm];
    } @catch (NSException *exception) {
        
        NSLog(@"Realm open failed: %@", exception.reason);

        NSFileManager *fm = [NSFileManager defaultManager];

        NSURL *realmURL = [RLMRealmConfiguration defaultConfiguration].fileURL;

        // realm 本体
        [fm removeItemAtURL:realmURL error:nil];

        // .lock
        NSURL *lockURL = [realmURL URLByAppendingPathExtension:@"lock"];
        [fm removeItemAtURL:lockURL error:nil];

        // .management
        NSURL *managementURL = [realmURL URLByAppendingPathExtension:@"management"];
        [fm removeItemAtURL:managementURL error:nil];

        // 再オープン（新規作成）
        [RLMRealm defaultRealm];
    }

    // 保存値クリア
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"KEY_LOCATION_ADDRESS"];
    [ud removeObjectForKey:@"KEY_LOCATION_LATITUDE"];
    [ud removeObjectForKey:@"KEY_LOCATION_LONGITUDE"];
    [ud removeObjectForKey:@"KEY_ALCOHOL_VALUE"];
    [ud removeObjectForKey:@"KEY_ALCOHOL_VALUE_DIV"];
    [ud removeObjectForKey:@"KEY_PHOTO"];
    [ud removeObjectForKey:@"KEY_INSPECTION_TIME"];
    [ud removeObjectForKey:@"KEY_BREATHALYZER_UUID"];
    [ud synchronize];
    
    return YES;
}

@end
