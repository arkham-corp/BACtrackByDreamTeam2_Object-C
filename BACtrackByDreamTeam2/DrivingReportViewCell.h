//
//  DrivingReportViewCell.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/10.
//

#import <UIKit/UIKit.h>

@interface DrivingReportViewCell : UITableViewCell
{
}

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *sendLabel;

+ (DrivingReportViewCell *) cell;
+ (NSString *) staticReuseIdentifier;
- (NSString *) reuseIdentifier;

@end
