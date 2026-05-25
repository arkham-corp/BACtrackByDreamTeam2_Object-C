//
//  DrivingReportDetailViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/04.
//

#import "DrivingReportDetailViewController.h"
#import "AppConsts.h"
#import "DrivingReportDetailViewCell.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReport.h"
#import "RealmLocalDataDrivingReportDetail.h"

@interface DrivingReportDetailViewController ()
{
    RLMResults *drivingReportDetailList;
}
@end

@implementation DrivingReportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"明細一覧"];
    
    buttonAdd.exclusiveTouch = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    buttonAdd.enabled = true;
    
    [self LoadData];
}

- (void)LoadData
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *preparedDrivingReport = [NSPredicate predicateWithFormat:@"_id=%d", self.driving_report_id];
    RealmLocalDataDrivingReport *drivingReport = [[RealmLocalDataDrivingReport objectsInRealm:realm withPredicate:preparedDrivingReport] firstObject];
    if ([drivingReport.send_flg isEqualToString:@"1"])
    {
        buttonAdd.enabled = false;
    }
    
    // 一覧取得
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"driving_report_id=%d", self.driving_report_id];
    drivingReportDetailList = [RealmLocalDataDrivingReportDetail objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    
    RLMSortDescriptor *sort1 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_start_hm" ascending:YES];
    RLMSortDescriptor *sort2 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_end_hm" ascending:YES];
    NSArray *sortDescriptor = [NSArray arrayWithObjects:sort1, sort2, nil];
    
    drivingReportDetailList = [drivingReportDetailList sortedResultsUsingDescriptors:sortDescriptor];
    
    UINib *cellNib = [UINib nibWithNibName:@"DrivingReportDetailViewCell" bundle:nil];
    [mTableView registerNib:cellNib forCellReuseIdentifier:[DrivingReportDetailViewCell staticReuseIdentifier]];
 
    mTableView.delegate = self;
    mTableView.dataSource = self;
    
    [mTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//row = 行数を指定するデリゲートメソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   //必ずNSInteger型を返してあげている。
   return [drivingReportDetailList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DrivingReportDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DrivingReportDetailViewCell staticReuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[DrivingReportDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[DrivingReportDetailViewCell staticReuseIdentifier]];
    }
    
    RealmLocalDataDrivingReportDetail *drivingReporDetail = drivingReportDetailList[indexPath.row];
    
    cell.destinationLabel.text = drivingReporDetail.destination;
    
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealmLocalDataDrivingReport *drivingReportDetail = drivingReportDetailList[indexPath.row];
    // 移動
    drivingReportDetailEditViewController = [[DrivingReportDetailEditViewController alloc] initWithNibName:@"DrivingReportDetailEditViewController" bundle:nil];
    drivingReportDetailEditViewController.driving_report_id = self.driving_report_id;
    drivingReportDetailEditViewController.driving_report_detail_id = drivingReportDetail._id;
    [self.navigationController pushViewController:drivingReportDetailEditViewController animated:YES];
}

- (IBAction)btnAddTouchUpInside:(id)sender {
    buttonAdd.enabled = false;
    // 移動
    drivingReportDetailEditViewController = [[DrivingReportDetailEditViewController alloc] initWithNibName:@"DrivingReportDetailEditViewController" bundle:nil];
    drivingReportDetailEditViewController.driving_report_id = self.driving_report_id;
    drivingReportDetailEditViewController.driving_report_detail_id = 0;
    [self.navigationController pushViewController:drivingReportDetailEditViewController animated:YES];
}

@end
