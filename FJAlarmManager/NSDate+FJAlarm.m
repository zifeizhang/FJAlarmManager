//
//  NSDate+FJAlarm.m
//  FJAlarmManager
//
//  Created by belter on 16/7/19.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "NSDate+FJAlarm.h"

@implementation NSDate (FJAlarm)
+ (NSDateFormatter *)alarmDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    return formatter;
}

+ (NSDateFormatter *)standardDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return formatter;
}

@end
