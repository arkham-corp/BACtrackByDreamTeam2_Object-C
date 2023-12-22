//
//  DrivingReportViewCell.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/11/10.
//

#import "DrivingReportViewCell.h"

@implementation DrivingReportViewCell

+ (NSString *)staticReuseIdentifier
{
    return @"DrivingReportViewCell";
}

- (NSString *)reuseIdentifier
{
    return [DrivingReportViewCell staticReuseIdentifier];
}

// Call this to get an autoreleased cell.
+ (DrivingReportViewCell *) cell
{
    DrivingReportViewCell *cell = nil;
    NSArray *top_level = [[NSBundle mainBundle] loadNibNamed:@"DrivingReportViewCell" owner:self options:nil];
    for(id obj in top_level)
    {
        if([obj isKindOfClass:[DrivingReportViewCell class]])
        {
            cell = (DrivingReportViewCell *) obj;
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
