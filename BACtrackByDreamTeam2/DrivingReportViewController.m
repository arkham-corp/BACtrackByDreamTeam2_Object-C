//
//  DrivingReportViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import "DrivingReportViewController.h"
#import "AppConsts.h"
#import "DrivingReportViewCell.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReport.h"
#import "RealmLocalDataDrivingReportDetail.h"

@interface DrivingReportViewController ()
{
    RLMResults *drivingReportList;
}
@end

@implementation DrivingReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"日報一覧"];
    
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
    
    // 一覧取得
// 20231211
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *company = [ud stringForKey:KEY_COMPANY];
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"company_code=%@", company];
    drivingReportList = [RealmLocalDataDrivingReport objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    //drivingReportList = [RealmLocalDataDrivingReport allObjects];
// 20231211
    
    RLMSortDescriptor *sort1 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_start_ymd" ascending:NO];
    RLMSortDescriptor *sort2 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"driving_end_ymd" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObjects:sort1, sort2, nil];

    drivingReportList = [drivingReportList sortedResultsUsingDescriptors:sortDescriptor];
    
    // 過去データ削除
    NSDate *deleteDate = [NSDate dateWithTimeIntervalSinceNow:(-7)*24*60*60];
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    NSString *strDeleteDate = [df stringFromDate:deleteDate];
    
    [realm beginWriteTransaction];
    for (RealmLocalDataDrivingReport *drivingReport in drivingReportList)
    {
        
//20231211
//        if ([drivingReport.send_flg isEqualToString:@"1"])
//        {
            NSString *start_ymd = drivingReport.driving_start_ymd;
            if ([start_ymd compare:strDeleteDate] != NSOrderedDescending)
            {
                NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"driving_report_id=%d", drivingReport._id];
                RLMResults *drivingReportDetailList = [RealmLocalDataDrivingReportDetail objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
                [realm deleteObjects:drivingReportDetailList];

                [realm deleteObject:drivingReport];
            }
//        }
        
    }
    [realm commitWriteTransaction];
    
    UINib *cellNib = [UINib nibWithNibName:@"DrivingReportViewCell" bundle:nil];
    [mTableView registerNib:cellNib forCellReuseIdentifier:[DrivingReportViewCell staticReuseIdentifier]];
    
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
   return [drivingReportList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DrivingReportViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DrivingReportViewCell staticReuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[DrivingReportViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[DrivingReportViewCell staticReuseIdentifier]];
    }
    
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyyMMdd"];
    
    NSDateFormatter *df2 =[[NSDateFormatter alloc] init];
    [df2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df2 setDateFormat:@"yyyy/MM/dd"];
    
    RealmLocalDataDrivingReport *drivingRepor = drivingReportList[indexPath.row];
    
    NSDate *driving_start_date = [df dateFromString:drivingRepor.driving_start_ymd];
    
    cell.dateLabel.text = [df2 stringFromDate:driving_start_date];
    if ([drivingRepor.send_flg isEqualToString:@"1"])
    {
        cell.sendLabel.text = @"済";
    }
    else
    {
        cell.sendLabel.text = @"未";
    }
    
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealmLocalDataDrivingReport *drivingReport = drivingReportList[indexPath.row];
    // 移動
    drivingReportEditViewController = [[DrivingReportEditViewController alloc] initWithNibName:@"DrivingReportEditViewController" bundle:nil];
    drivingReportEditViewController._id = drivingReport._id;
    [self.navigationController pushViewController:drivingReportEditViewController animated:YES];
    
}

- (IBAction)btnAddTouchUpInside:(id)sender {
    buttonAdd.enabled = false;
    // 移動
    drivingReportEditViewController = [[DrivingReportEditViewController alloc] initWithNibName:@"DrivingReportEditViewController" bundle:nil];
    drivingReportEditViewController._id = 0;
    [self.navigationController pushViewController:drivingReportEditViewController animated:YES];
}

@end
