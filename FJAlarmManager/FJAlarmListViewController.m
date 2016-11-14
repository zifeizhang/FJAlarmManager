//
//  FJAlarmListViewController.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJAlarmListViewController.h"
#import "FJAlarm.h"
#import "FJAlarmCell.h"
#import "FJAlarmEditViewController.h"
#import "FJCoreDataManager.h"

@interface FJAlarmListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@end

@implementation FJAlarmListViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    // 获取本地数据
    self.dataSourceArr = [[FJCoreDataManager manager] fetchAllAlarm];
    [self.listTableView reloadData];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FJAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FJAlarmCell" owner:nil options:nil]firstObject];
    }
    
    FJAlarm *alarm = self.dataSourceArr[indexPath.row];
    cell.alarm = alarm;
    
    // 闹钟开/关回调
    cell.alarmStateChanged = ^(NSString *open){
        
        alarm.open = open;
        
        // 1.更新本地数据
        [[FJCoreDataManager manager] updateAlarmWithAlarmID:alarm.alarmID isOpen:alarm.open];

        // 2.推送开/关
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        if ([alarm.open isEqualToString:@"1"]) {
            [app scheduleLocalNotificationWithAlarmID:alarm.alarmID];
        }else if ([alarm.open isEqualToString:@"0"]){
            [app cancelLocalNotificationWithAlarmID:alarm.alarmID];
        }
        
    };
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FJAlarm *alarm = self.dataSourceArr[indexPath.row];
    
    FJAlarmEditViewController *editVC = [[FJAlarmEditViewController alloc]init];
    editVC.alarm = alarm;
    [self.navigationController pushViewController:editVC animated:YES];
    
}

// 左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FJAlarm *deleteAlarm = self.dataSourceArr[indexPath.row];
        NSString *deleteID = deleteAlarm.alarmID;
        BOOL alarmState = [deleteAlarm.open boolValue];
        
        // 1.删除数据源
        [self.dataSourceArr removeObjectAtIndex:indexPath.row];
        [[FJCoreDataManager manager] deleteAlarmWithAlarmID:deleteID];
        
        
        // 2.UI删除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        // 3.移除通知
        if (alarmState) {
            
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            [app cancelLocalNotificationWithAlarmID:deleteID];
        }
    }
}

#pragma mark - click
- (IBAction)addAlarmClick:(id)sender {

    FJAlarmEditViewController *editVC = [[FJAlarmEditViewController alloc]init];
    [self.navigationController pushViewController:editVC animated:YES];
}


#pragma mark - getter
- (NSMutableArray *)dataSourceArr
{
    if (!_dataSourceArr) {
        
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
