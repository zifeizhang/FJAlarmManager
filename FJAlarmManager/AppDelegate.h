//
//  AppDelegate.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class FJAlarm;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 新增通知
- (void)scheduleLocalNotificationWithAlarmID:(NSString *)alarmID;

// 取消本地通知
- (void)cancelLocalNotificationWithAlarmID:(NSString *)alarmID;

@end

