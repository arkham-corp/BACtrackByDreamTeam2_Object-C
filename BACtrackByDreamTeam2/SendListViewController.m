//
//  SendListViewController.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2023/10/17.
//

#import "AppConsts.h"
#import "Realm/Realm.h"
#import "RealmLocalDataAlcoholResult.h"
#import "SendListViewCell.h"
#import "SendListViewController.h"

@interface SendListViewController ()
{
    RLMResults *alcoholResultList;
}
@end

@implementation SendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"送信一覧"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self LoadData];
}

- (void)LoadData
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // 一覧取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *company = [ud stringForKey:KEY_COMPANY];
    NSPredicate *preparedDrivingReportDetail = [NSPredicate predicateWithFormat:@"company_code=%@", company];
    alcoholResultList = [RealmLocalDataAlcoholResult objectsInRealm:realm withPredicate:preparedDrivingReportDetail];
    
    RLMSortDescriptor *sort1 = [RLMSortDescriptor sortDescriptorWithKeyPath:@"inspection_time" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObjects:sort1, nil];

    alcoholResultList = [alcoholResultList sortedResultsUsingDescriptors:sortDescriptor];
    
    UINib *cellNib = [UINib nibWithNibName:@"SendListViewCell" bundle:nil];
    [mTableView registerNib:cellNib forCellReuseIdentifier:[SendListViewCell staticReuseIdentifier]];
    
    mTableView.delegate = self;
    mTableView.dataSource = self;
    
    [mTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//row = 行数を指定するデリゲートメソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   //必ずNSInteger型を返してあげている。
   return [alcoholResultList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SendListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SendListViewCell staticReuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SendListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SendListViewCell staticReuseIdentifier]];
    }
    
    RealmLocalDataAlcoholResult *alcoholResult = alcoholResultList[indexPath.row];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",alcoholResult.inspection_time];
    if ([alcoholResult.send_flg isEqualToString:@"0"])
    {
        cell.sendLabel.text = @"未";
    }
    else if ([alcoholResult.send_flg isEqualToString:@"1"])
    {
        cell.sendLabel.text = @"NG";
    } else
    {
        cell.sendLabel.text = @"済";
    }
    
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealmLocalDataAlcoholResult *alcoholResult = alcoholResultList[indexPath.row];
    // 移動
    transmissionContentView = [[TransmissionContentView alloc] initWithNibName:@"TransmissionContentView" bundle:nil];
    transmissionContentView._id = alcoholResult._id;
    [self.navigationController pushViewController:transmissionContentView animated:YES];
    
}


@end
