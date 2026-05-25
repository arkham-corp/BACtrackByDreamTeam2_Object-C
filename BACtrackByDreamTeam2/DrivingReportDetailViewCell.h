//
//  DrivingReportDetailViewCell.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/04.
//

#import <UIKit/UIKit.h>

@interface DrivingReportDetailViewCell : UITableViewCell
{
}
@property (retain, nonatomic) IBOutlet UILabel *destinationLabel;

+ (DrivingReportDetailViewCell *) cell;
+ (NSString *) staticReuseIdentifier;
- (NSString *) reuseIdentifier;

@end
