//
//  RealmLocalDataDrivingReportDetail.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/06.
//

#import <Realm/Realm.h>

@interface RealmLocalDataDrivingReportDetail : RLMObject
@property int _id; // Intended primary key
@property int driving_report_id;
@property NSString *destination;
@property NSString *driving_start_hm;
@property double driving_start_km;
@property NSString *driving_end_hm;
@property double driving_end_km;
@property NSString *cargo_weight;
@property NSString *cargo_status;
@property NSString *note;

@end


