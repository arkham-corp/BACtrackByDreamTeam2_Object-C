//
//  DrivingReportDestinationViewCell.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/06.
//

#import <UIKit/UIKit.h>

@interface DrivingReportDestinationViewCell : UITableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *destinationLabel;
@property (retain, nonatomic) IBOutlet UIButton *buttonDelete;

+ (DrivingReportDestinationViewCell *) cell;
+ (NSString *) staticReuseIdentifier;
- (NSString *) reuseIdentifier;
@end
