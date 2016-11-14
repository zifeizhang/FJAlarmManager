//
//  FJAlarmCell.h
//  FJAlarmManager
//
//  Created by belter on 16/7/12.
//  Copyright © 2016年 ebelter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FJAlarm;

@interface FJAlarmCell : UITableViewCell

@property (nonatomic,strong) FJAlarm *alarm;
@property (nonatomic,strong) void(^alarmStateChanged) (NSString *open);    //闹钟开关
@end
