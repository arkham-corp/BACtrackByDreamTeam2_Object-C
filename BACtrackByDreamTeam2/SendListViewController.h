//
//  SendListViewController.h
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import <UIKit/UIKit.h>
#import "TransmissionContentView.h"

@interface SendListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *mTableView;
    TransmissionContentView *transmissionContentView;
}

@end
