//
//  SendListViewCell.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/14.
//

#import "SendListViewCell.h"

@implementation SendListViewCell

+ (NSString *)staticReuseIdentifier
{
    return @"SendListViewCell";
}

- (NSString *)reuseIdentifier
{
    return [SendListViewCell staticReuseIdentifier];
}

// Call this to get an autoreleased cell.
+ (SendListViewCell *) cell
{
    SendListViewCell *cell = nil;
    NSArray *top_level = [[NSBundle mainBundle] loadNibNamed:@"SendListViewCell" owner:self options:nil];
    for(id obj in top_level)
    {
        if([obj isKindOfClass:[SendListViewCell class]])
        {
            cell = (SendListViewCell *) obj;
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
