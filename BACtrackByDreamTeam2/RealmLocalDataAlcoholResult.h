//
//  RealmLocalDataAlcoholResult.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/15.
//
#import <Realm/Realm.h>

@interface RealmLocalDataAlcoholResult : RLMObject
@property int _id; // Intended primary key
@property NSString *company_code;
@property NSString *inspection_time;
@property NSString *inspection_ymd;
@property NSString *inspection_hm;
@property NSString *driver_code;
@property NSString *car_number;
@property NSString *location_name;
@property NSString *location_lat;
@property NSString *location_long;
@property NSString *driving_div;
@property NSString *alcohol_value;
@property NSString *blood_alcohol_value;
@property NSString *breath_alcohol_Value;
@property NSData *photo_file;
@property NSString *use_Number;
@property NSString *backtrack_id;
@property NSString *send_flg;

@end
