//
//  FJUtility.m
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import "FJUtility.h"
#import "FJAlarm.h"

@implementation FJUtility
// 数字 --> 汉字
+ (NSString *)weekdayName:(NSString *)weekdayNum
{
    NSString *name = @"";
    NSInteger num = [weekdayNum integerValue];
    switch (num) {
            
        case 0:
            name = @"一律不";
            break;
        case 1:
            name = @"周一";
            break;
        case 2:
            name = @"周二";
            break;
        case 3:
            name = @"周三";
            break;
        case 4:
            name = @"周四";
            break;
        case 5:
            name = @"周五";
            break;
        case 6:
            name = @"周六";
            break;
        case 7:
            name = @"周日";
            break;
            
        default:
            break;
    }
    return name;
}
+ (NSString *)weekdayNum:(NSString *)weekdayName
{
    NSString *num = @"";
    if ([weekdayName isEqualToString:@"一律不"]) {
        
        num = @"0";
        
    }else if ([weekdayName isEqualToString:@"周一"]){
        
        num = @"1";
    }else if ([weekdayName isEqualToString:@"周二"]){
        
        num = @"2";
        
    }else if ([weekdayName isEqualToString:@"周三"]){
        
        num = @"3";
        
    }else if ([weekdayName isEqualToString:@"周四"]){
        
        num = @"4";
        
    }else if ([weekdayName isEqualToString:@"周五"]){
        
        num = @"5";
        
    }else if ([weekdayName isEqualToString:@"周六"]){
        
        num = @"6";
        
    }else if ([weekdayName isEqualToString:@"周日"]){
        
        num = @"7";
    
    }
    
    return num;
}

+ (NSString *)repeatCycleStrWithWeekdays:(NSArray *)weekdays
{
    NSString *repeatStr = @"";
    if (weekdays.count == 0) {
        
        repeatStr = @"一律不";
        
    }else if (weekdays.count == 7){
        
        repeatStr = @"每天";
    }else
    {
        NSMutableString *weekdayStr = [NSMutableString string];
        for (int i = 0; i < weekdays.count; i++) {
            
            [weekdayStr appendString: [NSString stringWithFormat:@"%@ ",[self weekdayName:weekdays[i]]]];
            
        }
        [weekdayStr substringToIndex:weekdayStr.length - 1];
        repeatStr = weekdayStr;
    }
    
    return repeatStr;

}
+ (NSArray *)weekdaysWithRepeatCycleStr:(NSString *)repeatCycle
{
    NSMutableArray *weekdays = [NSMutableArray array];
    if ([repeatCycle isEqualToString:@"一律不"]) {
        
    }else if ([repeatCycle isEqualToString:@"每天"]){
        
        weekdays = [@[@"1",@"2",@"3",@"4",@"5",@"6",@"7"] mutableCopy];
        
    }else
    {
        // 去除前后空格
        repeatCycle = [repeatCycle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *arr = [repeatCycle componentsSeparatedByString:@" "];
        
        for (int i = 0; i < arr.count; i++) {
            
            [weekdays addObject:[self weekdayNum:arr[i]]];

        }
    }
    return weekdays;
}


@end
