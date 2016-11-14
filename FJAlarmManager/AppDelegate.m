//
//  AppDelegate.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "AppDelegate.h"
#import "FJAlarmListViewController.h"
#import "FJAlarm.h"
#import "NSDate+FJAlarm.h"
#import "FJUtility.h"
#import "FJCoreDataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[FJAlarmListViewController alloc]init]];
    
    
    
    // 第一次安装，移除所有
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    return YES;
}
#pragma mark - 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Did Receive LocalNotification:【%@】",notification);

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAttributedString *alertMsg = [[NSAttributedString alloc]initWithString:notification.alertBody attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0],NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:188/255.0 blue:212/255.0 alpha:1]}];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert setValue:alertMsg forKey:@"attributedMessage"];
        alert.view.tintColor = [UIColor colorWithRed:0 green:188/255.0 blue:212/255.0 alpha:1];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"跳转任务界面");
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"取消");
            
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        
    });
    
    
}

#pragma mark - public Methods
// 新增通知
- (void)scheduleLocalNotificationWithAlarmID:(NSString *)alarmID
{

    /*-------------------- 获取闹钟数据 -------------------*/
    FJAlarm *alarm = [[FJCoreDataManager manager] fetchAlarmWithAlarmID:alarmID];

    /*-------------------- 计算需要重复的weekday -------------------*/
    NSDate *dateNow = [NSDate date];
    
    NSArray *clockTimeArr = [alarm.time componentsSeparatedByString:@":"];     // 00:00
    
    NSArray *weekdays = [FJUtility weekdaysWithRepeatCycleStr:alarm.repeatCycle];
//    NSLog(@"Repeat Cycle = %@",weekdays);
    
    // repeatCycle == “一律不”
    if (!weekdays.count) {
        
        
        [self scheduleSingleLocalNotificationWithAlarm:alarm];

        return;
        
    }
    
    // 1. 实例化一个日历对象
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // 通过已定义的日历对象，获取某个时间点的 NSDateComponents 表示
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    // 设置需要哪些信息
    //（NSCalendarUnitQuarter：季度，NSCalendarUnitWeekday：周几，NSCalendarUnitWeekOfYear：该年第几周）
    NSInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter;
    
    comps = [calendar components:unitFlags fromDate:dateNow];
    [comps setHour:[[clockTimeArr objectAtIndex:0] intValue]];
    [comps setMinute:[[clockTimeArr objectAtIndex:1] intValue]];
    [comps setSecond:0];
    
    
    
    // 2. 计算选中的 weekday
    Byte weekdayNow = [comps weekday];  // 当前周几
    
    // weekdays num (周一=1 ,周二=2 ,周三=3,... ,周日=7 )
    // -->
    // 转化系统格式的weekday num (周日=1 ,周一=2 ,周二=3,... ,周六=7 )
    Byte clockDays[7];
    for (int i = 0; i < weekdays.count; i++) {
        
        int day = [weekdays[i] intValue];
        if (day == 7) {
            clockDays[i] = 1;
        }else
        {
            clockDays[i] = day + 1;
        }
//        NSLog(@"clockDay = %hhu",clockDays[i]);
    }

    
    // 3. 添加本地通知
    int temp = 0;
    int days = 0;
    for (int i = 0; i < weekdays.count; i++) {
        
        // 计算相差几天
        temp = clockDays[i] - weekdayNow;
        days = ( temp >= 0 ? temp : temp + 7 );
        
        // [calendar dateFromComponents:comps]: 根据设置的comps获取历法中与之对应的时间点
        NSDate *newFireDate = [[calendar dateFromComponents:comps] dateByAddingTimeInterval:3600 * 24 * days];
        //NSLog(@"newFireDate = %@",[[NSDate standardDateFormatter] stringFromDate:newFireDate]);
        
        // 添加通知
        // 1. 建立通知
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        if (notification) {
            
            // 设置触发通知的时间
            notification.fireDate = newFireDate;
            // 时区
            //  notification.timeZone = [NSTimeZone defaultTimeZone];
            // 设置重复的间隔
            notification.repeatInterval = NSCalendarUnitWeekOfYear;
            // 通知内容
            notification.alertBody = alarm.matter.length > 0 ? [NSString stringWithFormat:@"该%@啦！",alarm.matter] : @"您有一个新提醒！";
            notification.alertAction = @"查看提醒";
            notification.hasAction = YES;
            notification.soundName = UILocalNotificationDefaultSoundName;
            
            // 通知参数
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:alarmID forKey:@"alarmID"];
            notification.userInfo = userInfo;
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                
                UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            }
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];

            
             NSLog(@"Post New LocalNotification ID:%@ at: %@",alarm.alarmID,[[NSDate standardDateFormatter] stringFromDate:notification.fireDate]);
        }

    }
    
//    NSLog(@"> Post New LocalNotification ID:%@",alarmID);
   
    
    /**** 打印当前所有本地通知 ****/
    /*
    NSMutableArray *infos = [NSMutableArray array];
    for (UILocalNotification *noti in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [infos addObject:[noti.userInfo valueForKey:@"alarmID"]];
    }
    if (infos.count > 1) {
        infos = [NSMutableArray arrayWithArray:[infos sortedArrayUsingSelector:@selector(compare:)]];
    }
    
    NSLog(@"scheduledLocalNotifications = %@",infos);
    */
    
}

// 不重复的提醒
- (void)scheduleSingleLocalNotificationWithAlarm:(FJAlarm *)alarm
{
    
    NSArray *clockTimeArr = [alarm.time componentsSeparatedByString:@":"];
    NSDate *nowDate = [NSDate date];
    
    
    // 实例化一个日历对象
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // 通过已定义的日历对象，获取某个时间点的 NSDateComponents 表示
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    // 设置需要哪些信息
    NSInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter;
    
    comps = [calendar components:unitFlags fromDate:nowDate];
    [comps setHour:[[clockTimeArr objectAtIndex:0] intValue]];
    [comps setMinute:[[clockTimeArr objectAtIndex:1] intValue]];
    [comps setSecond:0];
    
    NSDate *fireDate = [calendar dateFromComponents:comps];
    NSTimeInterval interval = [fireDate timeIntervalSinceDate:nowDate];
    if (interval < 0) {
        
        fireDate = [fireDate dateByAddingTimeInterval:24*60*60];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    if (notification) {
        
        // 设置触发通知的时间
        notification.fireDate = fireDate;
        // 时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复的间隔
        notification.repeatInterval = 0;
        // 通知内容
        notification.alertBody = alarm.matter.length > 0 ? [NSString stringWithFormat:@"该%@啦！",alarm.matter] : @"您有一个新提醒！";
        notification.alertAction = @"查看提醒";
        notification.hasAction = YES;
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 通知参数
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:alarm.alarmID forKey:@"alarmID"];
        notification.userInfo = userInfo;
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            
            UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
    }

    NSLog(@"Post Single LocalNotification ID:%@ at: %@",alarm.alarmID,[[NSDate standardDateFormatter] stringFromDate:notification.fireDate]);
    
}


// 取消本地通知
- (void)cancelLocalNotificationWithAlarmID:(NSString *)alarmID
{
    
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *notification in localNotifications) {
        
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            
            if ([[userInfo objectForKey:@"alarmID"] isEqualToString:alarmID]) {
                
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                NSLog(@"Cancel LocalNotification ID:%@ at: %@",alarmID,[[NSDate standardDateFormatter] stringFromDate:notification.fireDate]);
            }

        }
    }
    
    /**** 打印当前所有本地通知 ****/
    /*
    NSMutableArray *infos = [NSMutableArray array];
    for (UILocalNotification *noti in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [infos addObject:[noti.userInfo valueForKey:@"alarmID"]];
    }
    if (infos.count > 1) {
        infos = [NSMutableArray arrayWithArray:[infos sortedArrayUsingSelector:@selector(compare:)]];
    }
    
    NSLog(@"scheduledLocalNotifications = %@",infos);
    */
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
