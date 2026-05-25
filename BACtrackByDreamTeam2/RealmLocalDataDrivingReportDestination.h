//
//  RealmLocalDataDrivingReportDestination.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/06.
//

#import <Realm/Realm.h>

@interface RealmLocalDataDrivingReportDestination : RLMObject
@property int _id;// Intended primary key
@property NSString *company_code;
@property NSString *destination;

@end
