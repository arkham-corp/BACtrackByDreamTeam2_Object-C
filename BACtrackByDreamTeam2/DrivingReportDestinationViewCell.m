//
//  DrivingReportDestinationViewCell.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/06.
//

#import "DrivingReportDestinationViewCell.h"

@implementation DrivingReportDestinationViewCell

+ (NSString *)staticReuseIdentifier
{
    return @"DrivingReportDestinationViewCell";
}

- (NSString *)reuseIdentifier
{
    return [DrivingReportDestinationViewCell staticReuseIdentifier];
}

// Call this to get an autoreleased cell.
+ (DrivingReportDestinationViewCell *) cell
{
    DrivingReportDestinationViewCell *cell = nil;
    NSArray *top_level = [[NSBundle mainBundle] loadNibNamed:@"DrivingReportDestinationViewCell" owner:self options:nil];
    for(id obj in top_level)
    {
        if([obj isKindOfClass:[DrivingReportDestinationViewCell class]])
        {
            cell = (DrivingReportDestinationViewCell *) obj;
            [cell setup];
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void) setup
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.contentView.backgroundColor = [UIColor orangeColor];
    }
    else
    {
        self.contentView.backgroundColor = [UIColor blackColor];
    }
}

@end
