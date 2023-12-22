//
//  AppConsts.h
//  AlcoholChecker
//
//  Created by COM-MAC on 2015/09/08.
//  Copyright © 2020年 COM-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConsts : NSObject

#define KEY_LOCATION_ADDRESS @"KEY_LOCATION_ADDRESS"
#define KEY_LOCATION_LATITUDE @"KEY_LOCATION_LATITUDE"
#define KEY_LOCATION_LONGITUDE @"KEY_LOCATION_LONGITUDE"

#define KEY_AGREEMENT @"KEY_AGREEMENT"
#define KEY_HTTP_URL @"KEY_HTTP_URL"
#define KEY_COMPANY @"KEY_COMPANY"
#define KEY_ALCOHOL_VALUE_DIV @"KEY_ALCOHOL_VALUE_DIV"
#define KEY_MENU_DRIVING_REPORT_ENABLED @"KEY_MENU_DRIVING_REPORT_ENABLED"
#define KEY_MENU_SEND_LIST @"KEY_MENU_SEND_LIST"
#define KEY_MENU_REMINDER_ENABLED @"KEY_MENU_REMINDER_ENABLED"
#define KEY_DRIVING_DIV @"DRIVING_DIV"
#define KEY_DRIVER @"KEY_DRIVER"
#define KEY_CAR_NO @"KEY_CAR_NO"
#define KEY_ALCOHOL_VALUE @"KEY_ALCOHOL_VALUE"
#define KEY_PHOTO @"KEY_PHOTO"
#define KEY_INSPECTION_TIME @"KEY_INSPECTION_TIME"
#define KEY_BREATHALYZER_UUID @"KEY_BREATHALYZER_UUID"
#define KEY_BREATHALYZER_USE_COUNT @"KEY_BREATHALYZER_USE_COUNT"
#define KEY_FREE_TITLE1 @"KEY_FREE_TITLE1"
#define KEY_FREE_TITLE2 @"KEY_FREE_TITLE2"
#define KEY_FREE_TITLE3 @"KEY_FREE_TITLE3"
#define KEY_SEND_FLG @"KEY_SEND_FLG"
#define KEY_CONECTION_STATUS @"KEY_CONECTION_STATUS"

#define APP_VERSION_URL @"http://itunes.apple.com/lookup?id="
#define APP_UPDATE_URL @"itms-apps://itunes.apple.com/app/id"
#define APP_ID @"1535413789"
#define TEST_FLG @"0"
#define CAREATE_TEST_DATA_FLG @"0"
#define HTTP_TEST_HOST_NAME @"128.0.3.32/com"
#define HTTP_HOST_NAME @"almanecloud.com"
#define HTTP_GET_API_URL @"alcoholmanager/linkmanager/api/getApplicationApiUrl"
#define HTTP_GET_MENU_CONTROL @"alcoholmanager/linkmanager/api/getApplicationMenuControl"
#define HTTP_COMPANY_CHECK @"HttpCompanyMasterCheckServlet"
#define HTTP_GET_ALCOHOL_VALUE_DIV @"HttpGetAlcoholValueDivServlet"
#define HTTP_DRIVER_CHECK @"HttpDriverMasterCheckServlet"
#define HTTP_CAR_NO_CHECK @"HttpCarNoMasterCheckServlet"
#define HTTP_WRITE_ALCOHOL_VALUE @"HttpWriteAlcoholResultServlet"
#define HTTP_WRITE_DRIVING_REPORT @"HttpWriteDrivingReport"
#define HTTP_GET_FREE_TITLE @"HttpGetFreeTitleServlet"

#define ALCHOL_REMOVEAL_RATE 0.015f

@end
