//
//  DrivingReportDestinationViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/12/06.
//

#import "DrivingReportDestinationViewController.h"
#import "AppConsts.h"
#import "DrivingReportDestinationViewCell.h"
#import "Realm/Realm.h"
#import "RealmLocalDataDrivingReportDestination.h"
#import "DrivingReportDetailEditViewController.h"

@interface DrivingReportDestinationViewController ()
{
    RLMResults *drivingReportDestinationList;
}
@end

@implementation DrivingReportDestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"行先一覧"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self LoadData];
}

- (void)LoadData
{
    // 一覧取得
//20231211
    //drivingReportDestinationList = [RealmLocalDataDrivingReportDestination allObjects];
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *company = [ud stringForKey:KEY_COMPANY];
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"company_code=%@", company];
    drivingReportDestinationList = [RealmLocalDataDrivingReportDestination objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
//20231211
    drivingReportDestinationList = [drivingReportDestinationList sortedResultsUsingKeyPath:@"destination" ascending:YES];
    
    UINib *cellNib = [UINib nibWithNibName:@"DrivingReportDestinationViewCell" bundle:nil];
    [mTableView registerNib:cellNib forCellReuseIdentifier:[DrivingReportDestinationViewCell staticReuseIdentifier]];
    
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
   return [drivingReportDestinationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DrivingReportDestinationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DrivingReportDestinationViewCell staticReuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[DrivingReportDestinationViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[DrivingReportDestinationViewCell staticReuseIdentifier]];
    }
    
    RealmLocalDataDrivingReportDestination *drivingReporDestination = drivingReportDestinationList[indexPath.row];
    
    cell.destinationLabel.text = drivingReporDestination.destination;
    
    // ボタン
    cell.buttonDelete.tag = indexPath.row;
    [cell.buttonDelete addTarget:self action:@selector(buttonDeleteDestinationTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealmLocalDataDrivingReportDestination *drivingReporDestination = drivingReportDestinationList[indexPath.row];
    // 移動
    NSArray * arr =  [self.navigationController viewControllers];
    DrivingReportDetailEditViewController *controller = arr[arr.count - 2];
    [controller setDestination:drivingReporDestination.destination];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonDeleteDestinationTouchUpInside:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認"
                                                                             message:@"削除しますか？"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
   //下記のコードでボタンを追加します。また{}内に記述された処理がボタン押下時の処理なります。
   [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
   {
       //ボタンがタップされた際の処理
       [self deleteData:sender.tag];
   }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        //ボタンがタップされた際の処理
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)deleteData:(long)rowIndex
{
    RealmLocalDataDrivingReportDestination *drivingReporDestination = drivingReportDestinationList[rowIndex];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:drivingReporDestination];
    [realm commitWriteTransaction];
    
    [self LoadData];
}

@end
