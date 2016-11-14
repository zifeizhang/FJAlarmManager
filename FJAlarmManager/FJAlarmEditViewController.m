//
//  FJAlarmEditViewController.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJAlarmEditViewController.h"
#import "FJSetRepeatViewController.h"
#import "FJSetMatterViewController.h"
#import "FJAlarm.h"
#import "FJUtility.h"
#import "NSDate+FJAlarm.h"
#import "FJCoreDataManager.h"


@interface FJAlarmEditViewController ()
@property (weak, nonatomic) IBOutlet UILabel *naviTitleLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *repeatResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterResultLabel;

@property (nonatomic,strong) NSDate *selectDate;
@property (nonatomic,assign) FJAlarmViewMode editMode;

@end

@implementation FJAlarmEditViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    // 设置初始值
    if (self.alarm) {
        
        self.editMode = FJAlarmViewModeEdit;
        self.naviTitleLabel.text = @"修改提醒";
        
        self.datePicker.date = [[NSDate alarmDateFormatter] dateFromString:self.alarm.time];
        self.selectDate = self.datePicker.date;
        self.repeatResultLabel.text = self.alarm.repeatCycle;
        self.matterResultLabel.text = self.alarm.matter;
        
        
    }else
    {
        // self.selectDate 默认返回当日
        self.alarm = [[FJAlarm alloc]init];
        self.editMode = FJAlarmViewModeAdd;
        self.naviTitleLabel.text = @"新增提醒";
    }
   
}
- (IBAction)dateChanged:(id)sender {
    
    self.selectDate = self.datePicker.date;
    
}

#pragma mark - click methods
- (IBAction)repeatTap:(UITapGestureRecognizer *)sender {
    
    FJSetRepeatViewController *repeatVC = [[FJSetRepeatViewController alloc]init];
    
    // repeatResultLabel.text不为空，则传入当前提醒日
    if (self.repeatResultLabel.text.length > 0) {
        
        repeatVC.resultArr = [[FJUtility weekdaysWithRepeatCycleStr:self.repeatResultLabel.text] mutableCopy];
    }

    // 回传提醒日
    repeatVC.repeatWeekdays = ^(NSMutableArray *weekdays){
        
        // 返回数组：2，3，4 --> 存储、显示：周二 周三 周四
        // NSLog(@"回传weekdays = %@",weekdays);
        self.repeatResultLabel.text = [FJUtility repeatCycleStrWithWeekdays:weekdays];
    };
    
    [self.navigationController pushViewController:repeatVC animated:YES];
    
}

- (IBAction)matterTap:(UITapGestureRecognizer *)sender {
    
    FJSetMatterViewController *matterVC = [[FJSetMatterViewController alloc]init];
    if (self.matterResultLabel.text.length > 0) {
        matterVC.matter = self.matterResultLabel.text;
    }
   
    matterVC.alarmMatter = ^(NSString *matterStr){
      
        self.matterResultLabel.text = matterStr;
    };
    
    [self.navigationController pushViewController:matterVC animated:YES];
}


- (IBAction)backButtonClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 保存闹钟
- (IBAction)saveButtonClick:(id)sender {

    if (self.repeatResultLabel.text.length == 0) {
        self.repeatResultLabel.text = @"一律不";
    }
    
    self.alarm.repeatCycle = self.repeatResultLabel.text;
    self.alarm.time = [[NSDate alarmDateFormatter] stringFromDate:self.selectDate];
    self.alarm.matter = self.matterResultLabel.text;
    self.alarm.open = [NSString stringWithFormat:@"%d",YES];
//    NSLog(@"alarm:\n%@,%@,%@",self.alarm.time,self.alarm.repeatCycle,self.alarm.matter);
    

    // 1.保存本地，更新通知
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    FJCoreDataManager *coreDataManager = [FJCoreDataManager manager];
    
    
    if (self.editMode == FJAlarmViewModeEdit) {
        
        [app cancelLocalNotificationWithAlarmID:self.alarm.alarmID];    // 取消编辑前的通知
        [coreDataManager updateAlarm:self.alarm withAlarmID:self.alarm.alarmID]; // 更新本地数据
        
        
    }else if (self.editMode == FJAlarmViewModeAdd){
 
        NSString *newID = [coreDataManager getNewAlarmID];
        if (!newID) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"添加提醒不能超过20个！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
            
        }else
        {
            self.alarm.alarmID = newID;
            [coreDataManager insertCoreDataWithAlarm:self.alarm];     // 新增本地数据
        }
        
        
    }
    
    // 新增本地通知
    [app scheduleLocalNotificationWithAlarmID:self.alarm.alarmID];
    
    [self.navigationController popViewControllerAnimated:YES];
 
}



#pragma mark - getter
- (NSDate *)selectDate
{
    if (!_selectDate) {
        _selectDate = [NSDate date];
    }
    return _selectDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
