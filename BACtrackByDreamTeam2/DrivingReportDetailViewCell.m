//
//  DrivingReportDetailViewCell.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/04.
//

#import "DrivingReportDetailViewCell.h"

@implementation DrivingReportDetailViewCell

+ (NSString *)staticReuseIdentifier
{
    return @"DrivingReportDetailViewCell";
}

- (NSString *)reuseIdentifier
{
    return [DrivingReportDetailViewCell staticReuseIdentifier];
}

// Call this to get an autoreleased cell.
+ (DrivingReportDetailViewCell *) cell
{
    DrivingReportDetailViewCell *cell = nil;
    NSArray *top_level = [[NSBundle mainBundle] loadNibNamed:@"DrivingReportDetailViewCell" owner:self options:nil];
    for(id obj in top_level)
    {
        if([obj isKindOfClass:[DrivingReportDetailViewCell class]])
        {
            cell = (DrivingReportDetailViewCell *) obj;
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
