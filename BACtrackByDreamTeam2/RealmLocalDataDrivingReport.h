//
//  RealmLocalDataDrivingReport.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/15.
//

#import <Realm/Realm.h>

@interface RealmLocalDataDrivingReport : RLMObject
@property int _id;
//20231211
@property NSString *company_code;
//20231211
@property NSString *driver_code;
@property NSString *car_number;
@property NSString *driving_start_ymd;
@property NSString *driving_start_hm;
@property NSString *driving_end_ymd;
@property NSString *driving_end_hm;
@property double driving_start_km;
@property double driving_end_km;
@property NSString *refueling_status;
@property NSString *abnormal_report;
@property NSString *instruction;
@property NSString *free_title1;
@property NSString *free_fld1;
@property NSString *free_title2;
@property NSString *free_fld2;
@property NSString *free_title3;
@property NSString *free_fld3;
@property NSString *send_flg;
@end


