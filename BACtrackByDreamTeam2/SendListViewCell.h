//
//  SendListViewCell.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/14.
//
#import <UIKit/UIKit.h>

@interface SendListViewCell : UITableViewCell
{
}

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *sendLabel;

+ (SendListViewCell *) cell;
+ (NSString *) staticReuseIdentifier;
- (NSString *) reuseIdentifier;

@end
