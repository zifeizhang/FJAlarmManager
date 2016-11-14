//
//  FJUtility.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FJUtility : NSObject
+ (NSString *)weekdayName:(NSString *)weekdayNum;
+ (NSString *)weekdayNum:(NSString *)weekdayName;
+ (NSString *)repeatCycleStrWithWeekdays:(NSArray *)weekdays;
+ (NSArray *)weekdaysWithRepeatCycleStr:(NSString *)repeatCycle;
@end
