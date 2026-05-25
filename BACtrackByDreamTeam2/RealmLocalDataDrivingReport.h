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
@property NSString *free_div1;
@property NSString *free_req1;
@property NSString *free_title2;
@property NSString *free_fld2;
@property NSString *free_div2;
@property NSString *free_req2;
@property NSString *free_title3;
@property NSString *free_fld3;
@property NSString *free_div3;
@property NSString *free_req3;
@property NSString *free_title4;
@property NSString *free_fld4;
@property NSString *free_div4;
@property NSString *free_req4;
@property NSString *free_title5;
@property NSString *free_fld5;
@property NSString *free_div5;
@property NSString *free_req5;
@property NSString *free_title6;
@property NSString *free_fld6;
@property NSString *free_div6;
@property NSString *free_req6;
@property NSString *free_title7;
@property NSString *free_fld7;
@property NSString *free_div7;
@property NSString *free_req7;
@property NSString *free_title8;
@property NSString *free_fld8;
@property NSString *free_div8;
@property NSString *free_req8;

@property NSString *send_flg;
@end


